import 'package:get/get.dart';
import '../Controllers/all_categories_controller.dart';
import '../Controllers/all_products_controller.dart';
import '../Controllers/all_users_controller.dart';
import '../Data/interfaces/categories_interfaces.dart';
import '../Data/interfaces/products_interfaces.dart';
import '../Data/interfaces/users_interfaces.dart';
import '../Data/repository/category_repository.dart';
import '../Data/repository/producst_repository.dart';
import '../Data/repository/users_repository.dart';
import '../Data/services/categories_services.dart';
import '../Data/services/products_services.dart';
import '../Data/services/users_services.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<Interfaces>(() => FirebaseAuthServices());
    Get.lazyPut<Interfaces>(() => UsersServices());
    Get.lazyPut<UsersRepository>(
        () => UsersRepository(interfaces: Get.find<Interfaces>()));

    Get.lazyPut<AllUsersController>(
        () => AllUsersController(usersRepository: Get.find<UsersRepository>()));
    //category repo
    Get.lazyPut<CategoryRepository>(
        () => CategoryRepository(interfaces: Get.find<CategoriesInterfaces>()));
    //category interfaces
    Get.lazyPut<CategoriesInterfaces>(() => CategoriesServices());
    //all categories controller
    Get.lazyPut<AllCategoriesController>(() => AllCategoriesController(
        categoryRepository: Get.find<CategoryRepository>()));

    //products
    Get.lazyPut<ProductsInterfaces>(() => ProductsServices());
    Get.lazyPut<ProducstRepository>(
        () => ProducstRepository(interfaces: Get.find<ProductsInterfaces>()));

    Get.lazyPut<AllProductsController>(() => AllProductsController(
        producstRepository: Get.find<ProducstRepository>()));
  }
}
