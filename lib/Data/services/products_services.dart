import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vav_foods_admin_app/Data/models/product_model.dart';

import '../interfaces/products_interfaces.dart';
import '../models/category_model.dart';

class ProductsServices implements ProductsInterfaces {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // Fetch category data from Firestore using categoryId
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot docSnapshot = await firebaseFirestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> categoryData =
            docSnapshot.data() as Map<String, dynamic>;
        return CategoryModel.fromMap(categoryData);
      } else {
        print("Category not found");
        return null;
      }
    } catch (e) {
      print("Error fetching category: $e");
      return null;
    }
  }

  //add
  @override
  Future<List<ProductModel>> addProductsToFirebase(
    String productName,
    String productDescription,
    double productPrice,
    String categoryId,
    String coverImg,
    List<String> urlImages,
    int stockQuantity,
    int stockThreshold,
  ) async {
    List<ProductModel> productsList = [];
    try {
      // Fetch the category using categoryId
      CategoryModel? category = await getCategoryById(categoryId);
      if (category == null) {
        print("Category not found, unable to add product");
        return [];
      }
      DocumentReference docRef = firebaseFirestore.collection('products').doc();
      final String productId = docRef.id;

      ProductModel productModel = ProductModel(
        productId: productId,
        productName: productName,
        productDescription: productDescription,
        productPrice: productPrice,
        categoryId: category.categoryId,
        categoryName: category.categoryName,
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
}
