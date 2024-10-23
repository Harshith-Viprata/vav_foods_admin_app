import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String productId;
  String productName;
  String productDescription;
  double productPrice;
  String categoryId;
  String categoryName;
  String coverImg;
  List<String> urlImages;
  int stockQuantity;
  int stockThreshold;
  Timestamp createdAt;
  Timestamp updatedAt;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.categoryId,
    required this.categoryName,
    required this.coverImg,
    required this.urlImages,
    required this.stockQuantity,
    required this.stockThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productPrice': productPrice,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'coverImg': coverImg,
      'urlImages': urlImages,
      'stockQuantity': stockQuantity,
      'stockThreshold': stockThreshold,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productDescription: map['productDescription'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      coverImg: map['coverImg'] ?? '',
      urlImages: List<String>.from(map['urlImages'] ?? []),
      stockQuantity: (map['stockQuantity'] ?? 0).toInt(),
      stockThreshold: (map['stockThreshold'] ?? 0).toInt(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
