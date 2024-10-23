import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vav_foods_admin_app/Data/models/category_model.dart';
import 'package:vav_foods_admin_app/Data/repository/products_repository.dart';
import '../Data/models/product_model.dart';
import '../Presentation/Admin/widgets/my_text.dart';

class AllProductsController extends GetxController {
  final ProductsRepository productsRepository;
  AllProductsController({required this.productsRepository});

  var isLoading = false.obs;
  var productsList = <ProductModel>[].obs;
  var categoryList = <CategoryModel>[].obs;

  // Category handling (selected category)
  Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);

  final ImagePicker imagePicker = ImagePicker();

  // For cover image
  Rx<XFile?> coverImage = Rx<XFile?>(null);
  Rx<Uint8List?> webCoverImageBytes = Rx<Uint8List?>(null);
  RxString uploadedCoverImageUrl = ''.obs;

  // For multiple selected images (urlImages)
  RxList<XFile> selectedImages = <XFile>[].obs;
  RxList<Uint8List> webImageBytesList = <Uint8List>[].obs;
  RxList<String> uploadedImageUrl = <String>[].obs;

  // Text Controllers
  TextEditingController productNameController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController stockQuantityController = TextEditingController();
  TextEditingController stockThresholdController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    productNameController.dispose();
    productDescriptionController.dispose();
    productPriceController.dispose();
    stockQuantityController.dispose();
    stockThresholdController.dispose();
    super.onClose();
  }

  // Fetch categories from Firebase
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await productsRepository.fetchCategoriesFromFirebase();
      // categoryList.assignAll(categories);
      if (categories != null && categories.isNotEmpty) {
        categoryList.value = categories;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Show image picking dialog with permissions handling for mobile
  Future<void> showImagesPickDialog({required bool isCoverImage}) async {
    if (kIsWeb) {
      showPickDialog(isCoverImage: isCoverImage);
    } else {
      PermissionStatus storageStatus;
      PermissionStatus cameraStatus;

      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;

      if (androidDeviceInfo.version.sdkInt < 32) {
        storageStatus = await Permission.storage.request();
        cameraStatus = await Permission.camera.request();
      } else {
        storageStatus = await Permission.mediaLibrary.request();
        cameraStatus = await Permission.camera.request();
      }

      if (storageStatus.isGranted && cameraStatus.isGranted) {
        showPickDialog(isCoverImage: isCoverImage);
      } else if (storageStatus.isDenied || cameraStatus.isDenied) {
        Get.snackbar('Error', 'Permissions denied, open app settings.');
        openAppSettings();
      }
    }
  }

  // Dialog to choose between single or multiple images
  void showPickDialog({required bool isCoverImage}) {
    Get.defaultDialog(
      title: "Choose Image",
      middleText: "Pick an image from the camera or gallery",
      actions: [
        ElevatedButton(
          onPressed: () {
            if (isCoverImage) {
              pickImage("Camera", isCoverImage: isCoverImage);
            } else {
              pickMultipleImages();
            }
            Get.back();
          },
          child: MyText(text: 'Camera'),
        ),
        ElevatedButton(
          onPressed: () {
            if (isCoverImage) {
              pickImage("Gallery", isCoverImage: isCoverImage);
            } else {
              pickMultipleImages();
            }
            Get.back();
          },
          child: MyText(text: 'Gallery'),
        ),
      ],
    );
  }

// Method to pick a single image (handles web and mobile)
  Future<void> pickImage(String sourceType,
      {required bool isCoverImage}) async {
    XFile? image;
    if (kIsWeb) {
      image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (isCoverImage) {
          webCoverImageBytes.value = bytes;
          coverImage.value = image;
        } else {
          webImageBytesList.add(bytes);
          selectedImages.add(image);
        }
      }
    } else {
      image = await imagePicker.pickImage(
          source:
              sourceType == 'Camera' ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 80);
      if (image != null) {
        if (isCoverImage) {
          coverImage.value = image;
        } else {
          selectedImages.add(image);
        }
      }
    }
  }

  // Method to pick multiple images (web and mobile)
  Future<void> pickMultipleImages() async {
    List<XFile>? images = await imagePicker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      selectedImages.addAll(images);
      if (kIsWeb) {
        for (var image in images) {
          final bytes = await image.readAsBytes();
          webImageBytesList.add(bytes);
        }
      }
    }
  }

  // Remove the selected cover image
  void removeSelectedCoverImage() {
    coverImage.value = null;
    webCoverImageBytes.value = null;
  }

  // Remove the selected multiple images
  void removeSelectedImages() {
    selectedImages.clear();
    webImageBytesList.clear();
  }

  //storage

  // Upload single and multiple images
  Future<void> uploadSelectedImages() async {
    if (coverImage.value != null) {
      final imageUrl = await productsRepository
          .uploadProductsImageToStorage(coverImage.value!);
      uploadedCoverImageUrl.value = imageUrl;
    }

    if (selectedImages.isNotEmpty) {
      for (var image in selectedImages) {
        final imageUrl =
            await productsRepository.uploadProductsImageToStorage(image);
        uploadedImageUrl.add(imageUrl);
      }
    }
  }

  Future<void> addProductsToFirebase() async {
    // Validate all fields
    if (productNameController.text.isEmpty ||
        productDescriptionController.text.isEmpty ||
        productPriceController.text.isEmpty ||
        stockQuantityController.text.isEmpty ||
        stockThresholdController.text.isEmpty ||
        coverImage.value == null ||
        selectedImages.isEmpty ||
        selectedCategory.value == null) {
      Get.snackbar('Error', 'Please fill all fields and select images');
      return;
    }

    try {
      isLoading.value = true;

      // Convert inputs to proper types with safety checks
      String productName = productNameController.text.trim();
      String productDescription = productDescriptionController.text.trim();
      double productPrice =
          double.tryParse(productPriceController.text.trim()) ?? 0.0;

      int stockQuantity =
          int.tryParse(stockQuantityController.text.trim()) ?? 0;
      int stockThreshold =
          int.tryParse(stockThresholdController.text.trim()) ?? 0;

      // Ensure selectedCategory is not null
      String categoryId = selectedCategory.value!.categoryId;
      String categoryName = selectedCategory.value!.categoryName;

      // Step 1: Upload the cover image to Firebase Storage and get the download URL
      String coverImageUrl = await productsRepository
          .uploadProductsImageToStorage(coverImage.value!);

      // Step 2: Upload the multiple images to Firebase Storage and get the download URLs
      List<String> urlImages = [];
      for (var image in selectedImages) {
        String imageUrl =
            await productsRepository.uploadProductsImageToStorage(image);
        urlImages.add(imageUrl);
      }

      // Add the product to Firebase using the repository with the updated model structure
      await productsRepository.addProductsToFirebase(
        productName,
        productDescription,
        productPrice, // Pass the parsed product price
        categoryId, // Pass the selected categoryId
        categoryName, // Pass the selected categoryName
        coverImageUrl, // Cover image path
        urlImages, // Multiple images as List<String>
        stockQuantity, // Pass stockQuantity as a String
        stockThreshold, // Pass stockThreshold as a String
      );

      // Clear the form after submission
      clearForm();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear the form after submission
  void clearForm() {
    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    stockQuantityController.clear();
    stockThresholdController.clear();
    coverImage.value = null;
    selectedImages.clear();
    selectedCategory.value = null;
    webCoverImageBytes.value = null;
    webImageBytesList.clear();
  }
}
