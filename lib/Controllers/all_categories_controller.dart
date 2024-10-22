import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vav_foods_admin_app/Data/models/category_model.dart';
import 'package:vav_foods_admin_app/Data/repository/category_repository.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_text.dart';

class AllCategoriesController extends GetxController {
  final CategoryRepository categoryRepository;
  AllCategoriesController({required this.categoryRepository});

  var isLoading = false.obs;
  var categoriesList = <CategoryModel>[].obs;
  Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);

  final ImagePicker imagePicker = ImagePicker(); // Image picker instance
  Rx<XFile?> selectedImage = Rx<XFile?>(null); // Single selected image
  Rx<Uint8List?> webImageByte = Rx<Uint8List?>(null); // For web image bytes
  RxString uploadedImageUrl = ''.obs; // Single image URL after upload

  // For category inputs
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryDescriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategoriesFromFirebase();
  }

  @override
  void onClose() {
    super.onClose();
    categoryNameController.dispose();
    categoryDescriptionController.dispose();
  }

  // Fetch categories from Firebase
  Future<void> fetchCategoriesFromFirebase() async {
    try {
      isLoading(true);
      final fetchCategories =
          await categoryRepository.fetchCategoriesFromFirebase();
      if (fetchCategories != null && fetchCategories.isNotEmpty) {
        categoriesList.value = fetchCategories;
      } else {
        print("No Categories Found");
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch a single category by ID
  Future<void> fetchCategoryById(String categoryId) async {
    try {
      isLoading(true);
      final CategoryModel? category =
          await categoryRepository.fetchsingleCategoryFromFirebase(categoryId);

      if (category != null) {
        selectedCategory.value = category;
        categoryNameController.text = category.categoryName;
        categoryDescriptionController.text = category.categoryDescription;
        uploadedImageUrl.value = category.categoryImg.isNotEmpty
            ? category.categoryImg
            : ''; // Update the image URL
      } else {
        print("Category not found.");
      }
    } catch (e) {
      print("Error fetching single category details: $e");
    } finally {
      isLoading(false);
    }
  }

  // Show image picking dialog with permissions handling for mobile
  Future<void> showImagesPickDialog() async {
    if (kIsWeb) {
      // No permissions required for the web, directly show pick dialog
      showPickDialog();
    } else {
      // Handle permissions for mobile (camera & storage)
      PermissionStatus storageStatus;
      PermissionStatus cameraStatus;

      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;

      if (androidDeviceInfo.version.sdkInt < 32) {
        // For Android versions less than 32, request storage and camera permissions
        storageStatus = await Permission.storage.request();
        cameraStatus = await Permission.camera.request();
      } else {
        // For Android 33 and above, request media and camera permissions
        storageStatus = await Permission.mediaLibrary.request();
        cameraStatus = await Permission.camera.request();
      }

      // If permissions are granted, show dialog to pick image
      if (storageStatus.isGranted && cameraStatus.isGranted) {
        showPickDialog();
      } else if (storageStatus.isDenied ||
          cameraStatus.isDenied ||
          storageStatus.isPermanentlyDenied ||
          cameraStatus.isPermanentlyDenied) {
        // Redirect the user to the app settings if permissions are denied
        print("Error: Permissions denied, open app settings.");
        openAppSettings();
      }
    }
  }

// Function to show dialog for choosing Camera or Gallery
  void showPickDialog() {
    Get.defaultDialog(
      title: "Choose Image",
      middleText: "Pick an image from the camera or gallery",
      actions: [
        ElevatedButton(
          onPressed: () {
            pickImage("Camera");
            Get.back(); // Close the dialog after selecting Camera
          },
          child: MyText(text: 'Camera'),
        ),
        ElevatedButton(
          onPressed: () {
            pickImage("Gallery");
            Get.back(); // Close the dialog after selecting Gallery
          },
          child: MyText(text: 'Gallery'),
        ),
      ],
    );
  }

  // Method to pick a single image (handles web and mobile)
  Future<void> pickImage(String sourceType) async {
    XFile? image;
    if (kIsWeb) {
      image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        webImageByte.value = bytes;
      }
    } else {
      image = await imagePicker.pickImage(
          source:
              sourceType == 'Camera' ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 80);
    }

    if (image != null) {
      selectedImage.value = image;
    }
  }

  // Remove the selected image
  void removeSelectedImage() {
    selectedImage.value = null;
    webImageByte.value = null;
  }

  // Upload the selected image to Firebase (delegated to repository)
  Future<void> uploadSelectedImage() async {
    if (selectedImage.value != null) {
      final imageUrl = await categoryRepository
          .uploadCategoryImageToStorage(selectedImage.value!);
      uploadedImageUrl.value = imageUrl; // Store the image URL
    }
  }

  // Add category to Firebase with image URL
  Future<void> addCategoryToFirebase() async {
    if (categoryNameController.text.isEmpty ||
        categoryDescriptionController.text.isEmpty ||
        uploadedImageUrl.isEmpty) {
      Get.snackbar('Error', 'Please provide all required fields and an image');
      return;
    }
    try {
      isLoading.value = true;

      // Add category to Firebase
      await categoryRepository.addCategoriesToFirebase(
        categoryNameController.text.trim(),
        categoryDescriptionController.text.trim(),
        uploadedImageUrl.value,
      );

      // Clear fields after successful addition
      categoryNameController.clear();
      categoryDescriptionController.clear();
      selectedImage.value = null;
      webImageByte.value = null;
      uploadedImageUrl.value = '';

      Get.snackbar('Success', 'Category added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //update

// Update category in Firebase with image URL
  Future<void> updateCategoriesFromFirebase(String categoryId) async {
    if (categoryNameController.text.isEmpty ||
        categoryDescriptionController.text.isEmpty ||
        uploadedImageUrl.isEmpty) {
      Get.snackbar('Error', 'Please provide all required fields and an image');
      return;
    }

    try {
      isLoading.value = true;

      // Check if a new image is selected, if so, upload it
      if (selectedImage.value != null) {
        final imageUrl = await categoryRepository
            .uploadCategoryImageToStorage(selectedImage.value!);
        uploadedImageUrl.value = imageUrl; // Update the image URL
      }

      // Update category in Firebase
      await categoryRepository.updateCategoryFromFirebase(
        categoryId,
        categoryNameController.text.trim(),
        categoryDescriptionController.text.trim(),
        uploadedImageUrl.value,
      );

      // Clear fields after successful update
      categoryNameController.clear();
      categoryDescriptionController.clear();
      selectedImage.value = null;
      webImageByte.value = null;
      uploadedImageUrl.value = '';

      Get.snackbar('Success', 'Category updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //delete
  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      isLoading.value = true;
      await categoryRepository.deleteImageFromStorage(imageUrl);
      print("Image deleted from Storage");
    } catch (e) {
      Get.snackbar("Error", "Failed while deleting the category image: $e");
      print("Error while deleting the category image: $e");
    } finally {
      isLoading.value = false;
    }
  }

//delete
  Future<void> deleteCategoryFromFirebase(String categoryId) async {
    try {
      isLoading.value = true;
      categoriesList.value =
          await categoryRepository.deleteUserFromFirebase(categoryId);
      Get.snackbar('Success', 'Category deleted successfully');
    } catch (e) {
      Get.snackbar("Error", "Failed to delete the Category: $e");
      print("Error deleting category: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
