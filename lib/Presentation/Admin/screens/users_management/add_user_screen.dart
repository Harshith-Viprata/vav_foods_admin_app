import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_button.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_text.dart';
import 'package:vav_foods_admin_app/Routes/routes.dart';
import '../../../../Constants/colors.dart';
import '../../../../Constants/responsive.dart';
import '../../../../Controllers/all_users_controller.dart';
import '../../../../Data/models/user_model.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/my_textFormField.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final AllUsersController allUsersController = Get.find<AllUsersController>();

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();

    // Schedule clearing of text controllers after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      allUsersController.userFullName.clear();
      allUsersController.userEmail.clear();
      allUsersController.userPhoneNumber.clear();
      allUsersController.userPassword.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MyAppBar(
            leading: IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.allUsersScreen);
                },
                icon: const Icon(
                  Icons.arrow_back,
                )),
            title: 'Add User Screen'),
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
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTextFormField(
                        controller: allUsersController.userFullName,
                        hintText: 'Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: allUsersController.userEmail,
                        hintText: 'Email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: allUsersController.userPhoneNumber,
                        hintText: 'Phone Number',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => DropdownButton<UserRole>(
                          dropdownColor: AppColors.background,
                          value: allUsersController.selectedRole.value,
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
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: allUsersController.userPassword,
                        hintText: 'Password',
                        obscureText: true, // Hide password
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => allUsersController.isLoading.value
                            ? const CupertinoActivityIndicator()
                            : MyButton(
                                minWidth: 200,
                                text: 'Add User',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await allUsersController.addUsersToFirebase(
                                      fullName: allUsersController
                                          .userFullName.text
                                          .trim(),
                                      email: allUsersController.userEmail.text
                                          .trim(),
                                      phoneNumber: allUsersController
                                          .userPhoneNumber.text
                                          .trim(),
                                      password: allUsersController
                                          .userPassword.text
                                          .trim(),
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
