import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Constants/colors.dart';
import '../../../../Constants/responsive.dart';
import '../../../../Controllers/all_users_controller.dart';
import '../../../../Routes/routes.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/my_drawer.dart';
import '../../widgets/my_text.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final AllUsersController allUsersController = Get.find<AllUsersController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: AppColors.background,
      appBar: MyAppBar(
        title: 'All Users Screen',
        actions: [
          IconButton(
              onPressed: () {
                Get.toNamed(AppRoutes.addUserScreen);
              },
              icon: Icon(
                Icons.add,
                color: AppColors.background,
              ))
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ||
                    Responsive.isDesktopLarge(context)
                ? MediaQuery.of(context).size.width * .5
                : Responsive.isTablet(context)
                    ? MediaQuery.of(context).size.width * .8
                    : Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width * 1
                        : MediaQuery.of(context).size.width * .9,
          ),
          child: Obx(() {
            if (allUsersController.isLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (allUsersController.usersList.isEmpty) {
              return Center(
                child: MyText(text: 'No users found'),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: allUsersController.usersList.length,
              itemBuilder: (context, index) {
                final user = allUsersController.usersList[index];
                return Dismissible(
                  movementDuration: const Duration(seconds: 2),
                  key: Key(user.userId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) async {
                    await allUsersController
                        .deleteUserFromFirebase(user.userId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Card(
                      color: AppColors.background,
                      elevation: 5,
                      child: ListTile(
                        onTap: () async {
                          // allUsersController.selectUser(user);
                          // await allUsersController.fetchUserById(user.userId);
                          Get.toNamed(AppRoutes.singleUserDetailsScreen,
                              arguments: user);
                        },
                        title: Text(user.fullName),
                        subtitle: Text(user.email),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyText(
                              text: user.role.toString().split('.').last,
                              color: AppColors.textcolor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            IconButton(
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.editUserDetailsScreen,
                                  arguments: user,
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: AppColors.textcolor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    ));
  }
}
