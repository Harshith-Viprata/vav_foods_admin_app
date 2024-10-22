import 'package:image_picker/image_picker.dart';

import '../interfaces/products_interfaces.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductsRepository {
  final ProductsInterfaces interfaces;
  ProductsRepository({required this.interfaces});

  //add
  Future<List<ProductModel>> addProductsToFirebase(
    String productName,
    String productDescription,
    double productPrice,
    String categoryId,
    String categoryName,
    String coverImg,
    List<String> urlImages,
    String stockQuantity,
    String stockThreshold,
  ) async {
    return interfaces.addProductsToFirebase(
      productName,
      productDescription,
      productPrice,
      categoryId,
      categoryName,
      coverImg,
      urlImages,
      stockQuantity,
      stockThreshold,
    );
  }

  Future<List<CategoryModel>> fetchCategoriesFromFirebase() async {
    return interfaces.fetchCategoriesFromFirebase();
  }

  Future<String> uploadProductsImageToStorage(XFile image) async {
    return interfaces.uploadProductImageToStorage(image);
  }
}
