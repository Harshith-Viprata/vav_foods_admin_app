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

  // Convert a ProductModel into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'productDescription': productDescription,
      'productPrice': productPrice,
      'categoryId': categoryId,
      'category_name': categoryName,
      'cover_img': coverImg,
      'url_images': urlImages,
      'stock_quantity': stockQuantity,
      'stock_threshold': stockThreshold,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Create a ProductModel from a Map (e.g., from Firestore)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'],
      productName: map['product_name'] ?? '',
      productDescription: map['productDescription'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      categoryName: map['category_name'] ?? '',
      coverImg: map['cover_img'] ?? '',
      urlImages: List<String>.from(map['url_images'] ?? []),
      stockQuantity: map['stock_quantity'] ?? 0,
      stockThreshold: map['stock_threshold'] ?? 0,
      createdAt: map['created_at'] ?? Timestamp.now(),
      updatedAt: map['updated_at'] ?? Timestamp.now(),
    );
  }
}
