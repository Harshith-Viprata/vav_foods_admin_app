import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vav_foods_admin_app/Data/models/category_model.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_text.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_textFormField.dart';
import '../../../../Controllers/all_categories_controller.dart';

class EditCategoryScreen extends StatefulWidget {
  EditCategoryScreen();

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final AllCategoriesController allCategoriesController =
      Get.find<AllCategoriesController>();

  String? categoryId;

  @override
  void initState() {
    super.initState();
    categoryId = (Get.arguments as CategoryModel?)?.categoryId;
    if (categoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        allCategoriesController.fetchCategoryById(categoryId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyText(text: 'Edit Category'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Delete the category from Firebase
              await allCategoriesController
                  .deleteCategoryFromFirebase(categoryId!);
              Get.back(); // Go back to the previous screen
            },
          ),
        ],
      ),
      body: Obx(() {
        if (allCategoriesController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display category details
        if (allCategoriesController.selectedCategory.value == null) {
          return Center(child: MyText(text: 'Category not found'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Name TextField
                CustomTextFormField(
                  controller: allCategoriesController.categoryNameController,
                  labelText: 'Category Name',
                ),
                const SizedBox(height: 10),

                // Category Description TextField
                CustomTextFormField(
                  controller:
                      allCategoriesController.categoryDescriptionController,
                  maxLines: 3,
                  labelText: 'Category Description',
                ),
                const SizedBox(height: 20),

                // Display Selected Image or Existing Image
                allCategoriesController.selectedImage.value != null
                    ? Image.memory(
                        allCategoriesController.webImageByte.value!,
                        height: 150,
                        width: 150,
                      )
                    : allCategoriesController.uploadedImageUrl.value.isNotEmpty
                        ? Image.network(
                            allCategoriesController.uploadedImageUrl.value,
                            height: 150,
                            width: 150,
                          )
                        : Container(),

                const SizedBox(height: 10),

                // Image picker button
                ElevatedButton.icon(
                  onPressed: () async {
                    // Show the image picker dialog
                    await allCategoriesController.showImagesPickDialog();
                  },
                  icon: const Icon(Icons.image),
                  label: MyText(text: 'Pick Image'),
                ),
                const SizedBox(height: 20),

                // Update Category Button
                ElevatedButton(
                  onPressed: () async {
                    // Upload the selected image if any
                    if (allCategoriesController.selectedImage.value != null) {
                      await allCategoriesController.uploadSelectedImage();
                    }

                    // Call the update category function
                    await allCategoriesController
                        .updateCategoriesFromFirebase(categoryId!);
                    Get.snackbar('Success', 'Category updated successfully');
                    Get.back(); // Navigate back after updating
                  },
                  child: MyText(text: 'Update Category'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
