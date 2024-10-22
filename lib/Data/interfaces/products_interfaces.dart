import 'package:vav_foods_admin_app/Data/models/product_model.dart';

abstract class ProductsInterfaces {
  Future<List<ProductModel>> addProductsToFirebase(
    String productName,
    String productDescription,
    double productPrice,
    String categoryId,
    String coverImg,
    List<String> urlImages,
    int stockQuantity,
    int stockThreshold,
  );
}
