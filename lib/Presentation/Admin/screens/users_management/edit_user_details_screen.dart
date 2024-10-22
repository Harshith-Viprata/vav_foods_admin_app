// ignore_for_file: unnecessary_null_comparison, prefer_if_null_operators

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Constants/colors.dart';
import '../../../../Constants/responsive.dart';
import '../../../../Controllers/all_users_controller.dart';
import '../../../../Data/models/user_model.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_text.dart';
import '../../widgets/my_textFormField.dart';

class EditUserDetailsScreen extends StatefulWidget {
  const EditUserDetailsScreen({super.key});

  @override
  State<EditUserDetailsScreen> createState() => _EditUserDetailsScreenState();
}

class _EditUserDetailsScreenState extends State<EditUserDetailsScreen> {
  final AllUsersController allUsersController = Get.find<AllUsersController>();
  String? userId;

  @override
  void initState() {
    super.initState();
    // Get userId from arguments
    userId = (Get.arguments as UserModel?)?.userId;

    // Fetch the user by userId safely within initState
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        allUsersController.fetchUserById(userId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Check if data is still loading
      if (allUsersController.isLoading.value) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: MyAppBar(title: 'User Details'),
          body: const Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      }

      final user = allUsersController.selectedUser.value;
      if (user == null) {
        return Scaffold(
          appBar: MyAppBar(title: 'User Details'),
          body: Center(
            child: MyText(text: 'No user data found.'),
          ),
        );
      }

      return SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: MyAppBar(
            title: 'Edit User Details',
          ),
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isDesktop(context) ||
                          Responsive.isDesktopLarge(context)
                      ? MediaQuery.of(context).size.width * .4
                      : Responsive.isTablet(context)
                          ? MediaQuery.of(context).size.width * .7
                          : Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width * 1
                              : MediaQuery.of(context).size.width * .9,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: allUsersController.userFullName,
                        hintText: 'Full Name',
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: allUsersController.userEmail,
                        hintText: 'Email',
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: allUsersController.userPhoneNumber,
                        hintText: 'Phone Number',
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<UserRole>(
                        dropdownColor: AppColors.background,
                        value: allUsersController.selectedRole.value != null
                            ? allUsersController.selectedRole.value
                            : UserRole.Admin,
                        onChanged: (UserRole? newRole) {
                          if (newRole != null) {
                            allUsersController.selectedRole(newRole);
                          }
                        },
                        items: UserRole.values.map((UserRole role) {
                          return DropdownMenuItem<UserRole>(
                            value: role,
                            child:
                                MyText(text: role.toString().split('.').last),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: allUsersController.userPassword,
                        hintText:
                            'Password', // Consider handling password updates separately
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                          minWidth: 200,
                          onPressed: () async {
                            if (allUsersController.userFullName.text.isEmpty ||
                                allUsersController.userEmail.text.isEmpty ||
                                allUsersController
                                    .userPhoneNumber.text.isEmpty) {
                              Get.snackbar('Error',
                                  'Please fill in all required fields.');
                              return;
                            }
                            await allUsersController.updateUserFromFirebase(
                              allUsersController.userFullName.text.trim(),
                              allUsersController.userEmail.text.trim(),
                              allUsersController.userPhoneNumber.text.trim(),
                              allUsersController.userPassword.text.trim(),
                              allUsersController.selectedRole.value,
                            );

                            // Get.toNamed(AppRoutes.allUsersScreen);
                          },
                          text: 'Update user'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
