import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/screens/category_management/edit_categories_screen.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_text.dart';
import '../../../../Constants/colors.dart';
import '../../../../Constants/responsive.dart';
import '../../../../Controllers/all_categories_controller.dart';
import '../../../../Routes/routes.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/my_drawer.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final AllCategoriesController allCategoriesController =
      Get.find<AllCategoriesController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const MyDrawer(),
        backgroundColor: AppColors.background,
        appBar: MyAppBar(
          title: 'All Categories Screen',
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(AppRoutes.addCategoriesScreen);
              },
              icon: Icon(
                Icons.add,
                color: AppColors.background,
              ),
            ),
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
              if (allCategoriesController.isLoading.value) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (allCategoriesController.categoriesList.isEmpty) {
                return Center(
                  child: MyText(text: "No Categories Found"),
                );
              }
              return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: allCategoriesController.categoriesList.length,
                  itemBuilder: (context, index) {
                    final category =
                        allCategoriesController.categoriesList[index];
                    return Dismissible(
                      key: Key(category.categoryId),
                      movementDuration: const Duration(seconds: 2),
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
                        await allCategoriesController
                            .deleteCategoryFromFirebase(category.categoryId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Card(
                          color: AppColors.background,
                          elevation: 5,
                          child: ListTile(
                            onTap: () async {
                              Get.toNamed(
                                AppRoutes.singleCategoryDetailsScreen,
                                arguments: category,
                              );
                            },
                            leading: ClipRRect(
                              child: CachedNetworkImage(
                                height: 100,
                                width: 100,
                                imageUrl: category.categoryImg,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        const CupertinoActivityIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            title:
                                MyText(text: "name: ${category.categoryName}"),
                            subtitle: MyText(
                                text: "des: ${category.categoryDescription}"),
                            trailing: IconButton(
                                onPressed: () {
                                  Get.toNamed(
                                    AppRoutes.editCategoriesScreen,
                                    arguments: category,
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                )),
                          ),
                        ),
                      ),
                    );
                  });
            }),
          ),
        ),
      ),
    );
  }
}
