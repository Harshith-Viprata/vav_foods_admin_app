import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vav_foods_admin_app/Constants/colors.dart';

import '../../../Routes/routes.dart';
import 'my_text.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 25),
      child: Drawer(
        backgroundColor: AppColors.primarygreen,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Wrap(
          runSpacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: MyText(
                  text: "Vav Foods Admin",
                  color: AppColors.background,
                ),
                subtitle: MyText(
                  text: "Version 1.0.1",
                  color: AppColors.background,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.background,
                  child: MyText(
                    text: "V",
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1.5,
            ),
            //home
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ListTile(
                onTap: () => Get.toNamed(AppRoutes.mainScreen),
                titleAlignment: ListTileTitleAlignment.center,
                title: MyText(
                  text: "Home",
                  color: AppColors.background,
                ),
                leading: Icon(
                  Icons.home,
                  color: AppColors.background,
                ),
              ),
            ),

            //users
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ListTile(
                onTap: () => Get.toNamed(AppRoutes.allUsersScreen),
                titleAlignment: ListTileTitleAlignment.center,
                title: MyText(
                  text: "Users",
                  color: AppColors.background,
                ),
                leading: Icon(
                  Icons.group,
                  color: AppColors.background,
                ),
                /* trailing: Icon(
                  Icons.arrow_forward,
                  color: AppConstant.appTextColor,
                ), */
              ),
            ),

            //categories
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ListTile(
                onTap: () => Get.toNamed(AppRoutes.allCategoriesScreen),
                titleAlignment: ListTileTitleAlignment.center,
                title: MyText(
                  text: "Categories",
                  color: AppColors.background,
                ),
                leading: Icon(
                  Icons.shopping_bag,
                  color: AppColors.background,
                ),
                /* trailing: Icon(
                  Icons.arrow_forward,
                  color: AppConstant.appTextColor,
                ), */
              ),
            ),
            //contact
            /*  Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: MyText(
                  text: "Contact",
                  color: AppConstant.appTextColor,
                ),
                leading: Icon(
                  Icons.help,
                  color: AppConstant.appTextColor,
                ),
              ),
            ), */
            //logout
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ListTile(
                onTap: () async {
                  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

                  await firebaseAuth.signOut();
                  // Get.toNamed(AppRoutes.welcomeScreen);
                },
                titleAlignment: ListTileTitleAlignment.center,
                title: MyText(
                  text: "Logout",
                  color: AppColors.background,
                ),
                leading: Icon(
                  Icons.logout,
                  color: AppColors.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
