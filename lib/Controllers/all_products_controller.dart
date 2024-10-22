import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vav_foods_admin_app/Data/repository/producst_repository.dart';

import '../Data/models/product_model.dart';

class AllProductsController extends GetxController {
  final ProducstRepository producstRepository;
  AllProductsController({required this.producstRepository});
  var isLoading = false.obs;
  var productsList = <ProductModel>[].obs;
  Rx<ProductModel?> selectedCategory = Rx<ProductModel?>(null);
  final ImagePicker imagePicker = ImagePicker();
  Rx<XFile?> selectedImage = Rx<XFile?>(null); // Single selected image
  Rx<Uint8List?> webImageByte = Rx<Uint8List?>(null); // For web image bytes
  RxString uploadedImageUrl = List<String>.obs;

  TextEditingController productNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Future<List<ProductModel>> addProductsToFirebase() async {}
}
