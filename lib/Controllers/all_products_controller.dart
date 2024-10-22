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
  //
  RxString uploadedCoverImageUrl = ''.obs;
  // For multiple selected images (urlImages)
  RxList<XFile> selectedImages = <XFile>[].obs;
  RxList<Uint8List> webImageBytesList =
      <Uint8List>[].obs; // For web image bytes
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
      showPickDialog(
          isCoverImage: isCoverImage); // No permissions needed on the web
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

  // Show dialog for choosing Camera or Gallery
  void showPickDialog({required bool isCoverImage}) {
    Get.defaultDialog(
      title: "Choose Image",
      middleText: "Pick an image from the camera or gallery",
      actions: [
        ElevatedButton(
          onPressed: () {
            pickImage(sourceType: "Camera", isCoverImage: isCoverImage);
            Get.back(); // Close the dialog after selecting Camera
          },
          child: MyText(text: 'Camera'),
        ),
        ElevatedButton(
          onPressed: () {
            pickImage(sourceType: "Gallery", isCoverImage: isCoverImage);
            Get.back(); // Close the dialog after selecting Gallery
          },
          child: MyText(text: 'Gallery'),
        ),
      ],
    );
  }

  // Method to pick a single or multiple images (handles web and mobile)
  Future<void> pickImage(
      {required String sourceType, required bool isCoverImage}) async {
    if (kIsWeb) {
      if (isCoverImage) {
        XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final bytes = await image.readAsBytes();
          webCoverImageBytes.value = bytes;
          coverImage.value = image;
        }
      } else {
        final List<XFile>? images = await imagePicker.pickMultiImage();
        if (images != null) {
          selectedImages.value = images;
          webImageBytesList.clear();
          for (var img in images) {
            webImageBytesList.add(await img.readAsBytes());
          }
        }
      }
    } else {
      if (isCoverImage) {
        XFile? image = await imagePicker.pickImage(
          source:
              sourceType == 'Camera' ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) {
          coverImage.value = image;
        }
      } else {
        final List<XFile>? images = await imagePicker.pickMultiImage();
        if (images != null) {
          selectedImages.value = images;
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

  Future<void> uploadSelectedImage() async {
    if (selectedImages.value != null) {}
  }

  Future<void> addProductsToFirebase() async {
    // Validate all fields
    if (productNameController.text.isEmpty ||
        productDescriptionController.text.isEmpty ||
        productPriceController.text.isEmpty ||
        stockQuantityController.text.isEmpty ||
        stockThresholdController.text.isEmpty ||
        /* coverImage.value == null ||
        selectedImages.isEmpty || */
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

      // Convert stockQuantity and stockThreshold to String
      String stockQuantity = stockQuantityController.text.trim();
      String stockThreshold = stockThresholdController.text.trim();

      // Ensure selectedCategory is not null
      String categoryId = selectedCategory.value!.categoryId;
      String categoryName = selectedCategory.value!.categoryName;

      // Cover image path
      String coverImg = coverImage.value!.path ?? '';

      // Multiple image paths for urlImages
      List<String> urlImages = selectedImages.map((img) => img.path).toList();

      // Add the product to Firebase using the repository with the updated model structure
      await productsRepository.addProductsToFirebase(
        productName,
        productDescription,
        productPrice, // Pass the parsed product price
        categoryId, // Pass the selected categoryId
        categoryName, // Pass the selected categoryName
        coverImg, // Cover image path
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
