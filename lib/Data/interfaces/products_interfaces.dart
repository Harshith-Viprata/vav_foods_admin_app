import 'package:image_picker/image_picker.dart';
import 'package:vav_foods_admin_app/Data/models/product_model.dart';

import '../models/category_model.dart';

abstract class ProductsInterfaces {
  Future<List<CategoryModel>> fetchCategoriesFromFirebase();
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
  );
  //store
  Future<String> uploadProductImageToStorage(XFile image);
}
