import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { Customer, Fulfillment, Delivery, Admin }

class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final UserRole role;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String userDeviceToken;
  final String userImg;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.userDeviceToken,
    required this.userImg,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role.toString().split('.').last,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userDeviceToken': userDeviceToken,
      'userImg': userImg,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'] ?? '',
      role: UserRole.values
          .firstWhere((e) => e.toString().split('.').last == map['role']),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      userDeviceToken: map['userDeviceToken'] ?? '',
      userImg: map['userImg'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}
