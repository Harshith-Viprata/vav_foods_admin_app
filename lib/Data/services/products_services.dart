import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vav_foods_admin_app/Data/models/product_model.dart';
import '../interfaces/products_interfaces.dart';
import '../models/category_model.dart';

class ProductsServices implements ProductsInterfaces {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  Future<List<CategoryModel>> fetchCategoriesFromFirebase() async {
    List<CategoryModel> categoriesList = [];

    try {
      QuerySnapshot snapshot =
          await firebaseFirestore.collection('categories').get();
      snapshot.docs.forEach((element) {
        categoriesList
            .add(CategoryModel.fromMap(element.data() as Map<String, dynamic>));
      });
    } catch (e) {
      print("Error in fetching the categories: $e");
    }

    return categoriesList;
  }

  @override
  Future<List<ProductModel>> addProductsToFirebase(
    String productName,
    String productDescription,
    double productPrice,
    String categoryId,
    String categoryName,
    String coverImg,
    List<String> urlImages,
    int stockQuantity,
    int stockThreshold,
  ) async {
    List<ProductModel> productsList = [];

    try {
      DocumentReference docRef = firebaseFirestore.collection('products').doc();
      final String productId = docRef.id;

      ProductModel productModel = ProductModel(
        productId: productId,
        productName: productName,
        productDescription: productDescription,
        productPrice: productPrice,
        categoryId: categoryId,
        categoryName: categoryName,
        coverImg: coverImg,
        urlImages: urlImages,
        stockQuantity: stockQuantity,
        stockThreshold: stockThreshold,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await firebaseFirestore
          .collection('products')
          .doc(productId)
          .set(productModel.toMap());
      productsList.add(productModel);
    } catch (e) {
      print("Error in adding the products: $e");
    }

    return productsList;
  }
  //store

  @override
  Future<String> uploadProductImageToStorage(XFile image) async {
    TaskSnapshot reference;
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      reference = await firebaseStorage
          .ref('product-images/${image.name + DateTime.now().toString()}')
          .putData(bytes);
    } else {
      reference = await firebaseStorage
          .ref('product-images/${image.name + DateTime.now().toString()}')
          .putFile(File(image.path));
    }

    return await reference.ref.getDownloadURL();
  }
}
