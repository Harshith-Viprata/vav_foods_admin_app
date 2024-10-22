import 'package:image_picker/image_picker.dart';
import '../interfaces/categories_interfaces.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final CategoriesInterfaces interfaces;

  CategoryRepository({required this.interfaces});

  //fetch

  Future<List<CategoryModel>> fetchCategoriesFromFirebase() async {
    return interfaces.fetchCategoriesFromFirebase();
  }

  //add
  Future<List<CategoryModel>> addCategoriesToFirebase(
    String categoryName,
    String categoryDescription,
    String categoryImg,
  ) async {
    return interfaces.addCategoriesToFirebase(
      categoryName,
      categoryDescription,
      categoryImg,
    );
  }

  //single category
  Future<CategoryModel?> fetchsingleCategoryFromFirebase(
      String categoryId) async {
    return await interfaces.fetchsingleCategoryFromFirebase(categoryId);
  }

  //store
  Future<String> uploadCategoryImageToStorage(XFile image) async {
    return interfaces.uploadCategoryImageToStorage(image);
  }

  //update

  Future<List<CategoryModel>> updateCategoryFromFirebase(
    String categoryId,
    String categoryName,
    String categoryDescription,
    String categoryImg,
  ) async {
    return interfaces.updateCategoryFromFirebase(
      categoryId,
      categoryName,
      categoryDescription,
      categoryImg,
    );
  }
  //delete images form strorage

  Future<String> deleteImageFromStorage(String imageUrl) async {
    return interfaces.deleteImageFromStorage(imageUrl);
  }

  //delete

  Future<List<CategoryModel>> deleteUserFromFirebase(String categoryId) async {
    return await interfaces.deleteCategoryFromFirebase(categoryId);
  }
}
