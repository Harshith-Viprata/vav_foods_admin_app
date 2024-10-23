import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_drawer.dart';
import '../../../../Constants/colors.dart';
import '../../../../Constants/responsive.dart';
import '../../../../Controllers/all_products_controller.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_text.dart';
import '../../widgets/my_textFormField.dart';

class AddProductsScreen extends StatefulWidget {
  const AddProductsScreen({super.key});

  @override
  State<AddProductsScreen> createState() => _AddProductsScreenState();
}

class _AddProductsScreenState extends State<AddProductsScreen> {
  final AllProductsController allProductsController =
      Get.find<AllProductsController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => allProductsController.isLoading.value
            ? const Center(child: CupertinoActivityIndicator())
            : Scaffold(
                drawer: const MyDrawer(),
                backgroundColor: AppColors.background,
                appBar: MyAppBar(
                  title: 'Add Products Screen',
                ),
                body: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.isDesktop(context) ||
                                Responsive.isDesktopLarge(context)
                            ? MediaQuery.of(context).size.width * .4
                            : Responsive.isTablet(context)
                                ? MediaQuery.of(context).size.width * .7
                                : MediaQuery.of(context).size.width,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Column(
                            children: [
                              // Product Name
                              CustomTextFormField(
                                hintText: 'Product Name',
                                controller:
                                    allProductsController.productNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter product name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Product Description
                              CustomTextFormField(
                                hintText: 'Product Description',
                                controller: allProductsController
                                    .productDescriptionController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter product description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Product Price
                              CustomTextFormField(
                                hintText: 'Product Price',
                                controller: allProductsController
                                    .productPriceController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter product price';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Stock Quantity
                              CustomTextFormField(
                                hintText: 'Stock Quantity',
                                controller: allProductsController
                                    .stockQuantityController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter stock quantity';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Stock Threshold
                              CustomTextFormField(
                                hintText: 'Stock Threshold',
                                controller: allProductsController
                                    .stockThresholdController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter stock threshold';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Select Category Dropdown
                              Obx(() => DropdownButtonFormField<String>(
                                    value: allProductsController
                                        .selectedCategory.value?.categoryId,
                                    hint: MyText(
                                      text: 'Select Category',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: allProductsController.categoryList
                                        .map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category.categoryId,
                                        child: Row(
                                          children: [
                                            category.categoryImg != null
                                                ? Image.network(
                                                    category.categoryImg!,
                                                    width: 40,
                                                    height: 40,
                                                  )
                                                : const SizedBox.shrink(),
                                            const SizedBox(width: 10),
                                            Text(category.categoryName),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      allProductsController
                                              .selectedCategory.value =
                                          allProductsController.categoryList
                                              .firstWhere((category) =>
                                                  category.categoryId == value);
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select a category';
                                      }
                                      return null;
                                    },
                                  )),
                              const SizedBox(height: 20),
                              // Cover Image Picker

                              // Cover Image Picker
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(text: 'Select Cover Image'),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Show the image picking dialog
                                      await allProductsController
                                          .showImagesPickDialog(
                                              isCoverImage: true);
                                      // After picking the image, upload it to Firebase Storage
                                      if (allProductsController
                                              .coverImage.value !=
                                          null) {
                                        await allProductsController
                                            .uploadedCoverImageUrl();
                                      }
                                    },
                                    child: MyText(text: 'Pick Cover Image'),
                                  ),
                                ],
                              ),

// Show cover image preview
                              allProductsController.coverImage.value != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: SizedBox(
                                        height: 300,
                                        width: 500,
                                        child: Stack(
                                          children: [
                                            kIsWeb
                                                ? Image.memory(
                                                    allProductsController
                                                        .webCoverImageBytes
                                                        .value!,
                                                    fit: BoxFit.cover,
                                                    height: 500,
                                                    width: 500,
                                                  )
                                                : Image.file(
                                                    File(allProductsController
                                                        .coverImage
                                                        .value!
                                                        .path),
                                                    fit: BoxFit.cover,
                                                    height: 500,
                                                    width: 500,
                                                  ),
                                            Positioned(
                                              right: 10,
                                              top: 0,
                                              child: InkWell(
                                                onTap: () {
                                                  allProductsController
                                                      .removeSelectedCoverImage();
                                                },
                                                child: const CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),

                              const SizedBox(height: 20),

// URL Images Picker (Multiple images)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(text: 'Select Multiple Images'),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Show the image picking dialog to pick multiple images
                                      await allProductsController
                                          .pickMultipleImages();
                                      // Upload selected images to Firebase Storage
                                      if (allProductsController
                                          .selectedImages.isNotEmpty) {
                                        await allProductsController
                                            .uploadSelectedImages();
                                      }
                                    },
                                    child: MyText(text: 'Pick Images'),
                                  ),
                                ],
                              ),

// Show selected images preview
                              allProductsController.selectedImages.isNotEmpty
                                  ? SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: allProductsController
                                            .webImageBytesList.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Stack(
                                              children: [
                                                kIsWeb
                                                    ? Image.memory(
                                                        allProductsController
                                                                .webImageBytesList[
                                                            index],
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(
                                                            allProductsController
                                                                .selectedImages[
                                                                    index]
                                                                .path),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: InkWell(
                                                    onTap: () {
                                                      allProductsController
                                                          .removeSelectedImages();
                                                    },
                                                    child: const CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),

                              const SizedBox(height: 20),

// Add Product Button
                              MyButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    allProductsController.isLoading.value =
                                        true;
                                    await allProductsController
                                        .addProductsToFirebase();
                                    allProductsController.isLoading.value =
                                        false;
                                  }
                                },
                                text: 'Add Product',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
