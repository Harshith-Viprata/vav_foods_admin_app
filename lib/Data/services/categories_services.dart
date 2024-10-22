// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vav_foods_admin_app/Data/interfaces/categories_interfaces.dart';
import 'package:vav_foods_admin_app/Data/models/category_model.dart';

class CategoriesServices implements CategoriesInterfaces {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

//fetch

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

//add
  @override
  Future<List<CategoryModel>> addCategoriesToFirebase(String categoryName,
      String categoryDescription, String categoryImg) async {
    List<CategoryModel> categoriesList = [];

    try {
      DocumentReference docRef =
          firebaseFirestore.collection('categories').doc();
      final String categoryId = docRef.id;
      CategoryModel categoryModel = CategoryModel(
        categoryId: categoryId,
        categoryName: categoryName,
        categoryDescription: categoryDescription,
        categoryImg: categoryImg,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      // Add category to Firebase (or perform any other operation)
      await firebaseFirestore
          .collection('categories')
          .doc(categoryId)
          .set(categoryModel.toMap());

      categoriesList.add(categoryModel);
    } catch (e) {
      print('Error adding category: $e');
    }
    return categoriesList;
  }

  //single category
  @override
  Future<CategoryModel?> fetchsingleCategoryFromFirebase(
      String categoryId) async {
    try {
      DocumentSnapshot categoryDoc = await firebaseFirestore
          .collection("categories")
          .doc(categoryId)
          .get();
      if (categoryDoc.exists) {
        return CategoryModel.fromMap(
            categoryDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching single category: $e");
    }
    return null;
  }

//store
  @override
  Future<String> uploadCategoryImageToStorage(XFile image) async {
    TaskSnapshot reference;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      reference = await firebaseStorage
          .ref('category-images/${image.name + DateTime.now().toString()}')
          .putData(bytes);
    } else {
      reference = await firebaseStorage
          .ref('category-images/${image.name + DateTime.now().toString()}')
          .putFile(File(image.path));
    }

    return await reference.ref.getDownloadURL();
  }

  //update teh category

  @override
  Future<List<CategoryModel>> updateCategoryFromFirebase(
    String categoryId,
    String categoryName,
    String categoryDescription,
    String categoryImg,
  ) async {
    List<CategoryModel> categoriesList = [];

    if (categoryId.isEmpty) {
      throw Exception("Category ID cannot be empty.");
    }

    try {
      final DocumentReference categoryDoc =
          firebaseFirestore.collection("categories").doc(categoryId);

      //fetch existing category details based on the created TimeStamp
      DocumentSnapshot existingCategoryDoc = await categoryDoc.get();
      if (!existingCategoryDoc.exists) {
        throw Exception("Category does not exist");
      }

      //exsisting category data

      Map<String, dynamic> existingCategoryData =
          existingCategoryDoc.data() as Map<String, dynamic>;

      Timestamp createdAt;

      //getting the existing category TimeStamp

      if (existingCategoryData['createdAt'] is Timestamp) {
        createdAt = existingCategoryData['createdAt'] as Timestamp;
      } else {
        throw Exception("Invalid createdAt format");
      }

      //prepare updated Category Model

      final CategoryModel categoryModel = CategoryModel(
        categoryId: categoryId,
        categoryName: categoryName,
        categoryDescription: categoryDescription,
        categoryImg: categoryImg,
        createdAt: createdAt,
        updatedAt: Timestamp.now(),
      );

      await categoryDoc.update(categoryModel.toMap());

      categoriesList = await fetchCategoriesFromFirebase();
    } catch (e) {
      print("Error updating the Category: $e");
    }

    return categoriesList;
  }

//  delete the images along with the category from the Storage and firestore

  @override
  Future<String> deleteImageFromStorage(String imageUrl) async {
    try {
      Reference reference = firebaseStorage.refFromURL(imageUrl);
      await reference.delete();
      print("Image deleted from Storage");
      return "Image successfully deleted from Storage"; // Return a success message
    } catch (e) {
      print("Error: $e");
      return "Error while deleting image from Storage: $e"; // Return the error message
    }
  }

  @override
  Future<List<CategoryModel>> deleteCategoryFromFirebase(
      String categoryId) async {
    List<CategoryModel> categoriesList = [];
    try {
      // Fetch the category document from Firestore
      DocumentSnapshot categorySnapshot = await firebaseFirestore
          .collection("categories")
          .doc(categoryId)
          .get();

      if (categorySnapshot.exists) {
        // Use the correct field name (categoryImg) instead of imageUrl
        String imageUrl = categorySnapshot[
            'categoryImg']; // Assuming it's called 'categoryImg'

        print("Deleting category: ${categorySnapshot.data()}");

        // Delete the image from Firebase Storage if imageUrl exists
        if (imageUrl.isNotEmpty) {
          try {
            // Create a reference from the image URL and delete it from Storage
            await firebaseStorage.refFromURL(imageUrl).delete();
            print("Category image deleted successfully.");
          } catch (e) {
            print("Error deleting category image from storage: $e");
          }
        }

        // Delete the category document from Firestore
        await firebaseFirestore
            .collection("categories")
            .doc(categoryId)
            .delete();
        print("Category data deleted from Firestore.");
      } else {
        print("Category does not exist");
      }
    } catch (e) {
      print("Error in deleting the category $e");
    }

    // Fetch updated categories list after deletion, if needed
    categoriesList = await fetchCategoriesFromFirebase();

    return categoriesList;
  }
}
