import '../interfaces/products_interfaces.dart';
import '../models/product_model.dart';

class ProducstRepository {
  final ProductsInterfaces interfaces;
  ProducstRepository({required this.interfaces});

  //add
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
    return interfaces.addProductsToFirebase(
      productName,
      productDescription,
      productPrice,
      categoryId,
      coverImg,
      urlImages,
      stockQuantity,
      stockThreshold,
    );
  }
}
