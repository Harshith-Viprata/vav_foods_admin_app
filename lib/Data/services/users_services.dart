// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vav_foods_admin_app/Data/models/user_model.dart';
import '../interfaces/users_interfaces.dart';

class UsersServices implements Interfaces {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> fetchUsersFromFirebase() async {
    List<UserModel> userList = [];
    try {
      QuerySnapshot snapshot =
          await firebaseFirestore.collection('users').get();
      for (var doc in snapshot.docs) {
        userList.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Error in fetching users: $e");
    }
    return userList;
  }

  @override
  Future<UserModel?> fetchsingleUserFromFirebase(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firebaseFirestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching single user: $e");
    }
    return null; //it will return null if there is no user
  }

  @override
  Future<List<UserModel>> addUsersToFirebase(
    String fullName,
    String email,
    String phoneNumber,
    String password,
    UserRole role,
  ) async {
    List<UserModel> userList = [];
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model object
      UserModel newUser = UserModel(
        userId: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        role: role, // Assign default role
        userDeviceToken: '',
        userImg: '',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        password: password,
      );

      // Save user data in Firestore with server-side timestamps
      await firebaseFirestore.collection('users').doc(newUser.userId).set({
        ...newUser.toMap(),
        'createdAt':
            FieldValue.serverTimestamp(), // Use Firestore server timestamp
        'updatedAt':
            FieldValue.serverTimestamp(), // Use Firestore server timestamp
      });

      // Fetch updated list of users from Firestore
      userList = await fetchUsersFromFirebase();
    } catch (e) {
      print("Error adding user: $e");
    }
    return userList;
  }

  @override
  Future<List<UserModel>> updateUserFromFirebase(
    String userId, // Add this parameter
    String fullName,
    String email,
    String phoneNumber,
    String password,
    UserRole role,
  ) async {
    List<UserModel> userList = [];

    // Check if the userId is provided
    if (userId.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }

    try {
      // Get reference to the user document in Firestore
      final DocumentReference userDoc = firebaseFirestore
          .collection('users')
          .doc(userId); // Use passed userId

      // Fetch existing user data to retain the createdAt timestamp
      DocumentSnapshot existingUserDoc = await userDoc.get();
      if (!existingUserDoc.exists) {
        throw Exception("User does not exist.");
      }
      //esxisting usre data

      Map<String, dynamic> existingUserData =
          existingUserDoc.data() as Map<String, dynamic>;

      Timestamp createdAt; // Keep as Timestamp

      //getting the existing user TimeStamp
      if (existingUserData['createdAt'] is Timestamp) {
        createdAt = existingUserData['createdAt'] as Timestamp;
      } else {
        throw Exception("Invalid createdAt format.");
      }

      // Prepare updated user model
      final UserModel updatedUserModel = UserModel(
        userId: userId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
        createdAt: createdAt, // Retain original createdAt timestamp
        updatedAt: Timestamp.now(), // Update the updatedAt timestamp
        userDeviceToken: '',
        userImg: '',
      );

      // Update Firestore fields
      await userDoc.update({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': role.toString().split('.').last,
        'updatedAt': Timestamp.now(), // Only updating updatedAt
        'userImg': '',
      });

      // If the email or password has changed, update Firebase Authentication
      final User? currentUser = firebaseAuth.currentUser;
      if (currentUser != null && userId == currentUser.uid) {
        if (email != currentUser.email) {
          await currentUser.updateEmail(email);
        }
        if (password.isNotEmpty) {
          await currentUser.updatePassword(password);
        }
      }

      // Fetch updated list of users from Firestore
      userList = await fetchUsersFromFirebase();
    } catch (e) {
      print("Error updating user: $e");
    }
    return userList;
  }

  @override
  Future<List<UserModel>> deleteUserFromFirebase(String userId) async {
    List<UserModel> userList = [];
    try {
      // Delete the user from Firestore
      await firebaseFirestore.collection('users').doc(userId).delete();

      // Optionally, you can also delete the user from Firebase Authentication if needed
      User? user = firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }

      // Fetch the updated list of users
      userList = await fetchUsersFromFirebase();
    } catch (e) {
      print("Error deleting user: $e");
    }
    return userList;
  }
}
