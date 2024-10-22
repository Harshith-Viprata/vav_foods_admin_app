import 'package:get/get.dart';
import 'package:vav_foods_admin_app/Data/interfaces/categories_interfaces.dart';
import 'package:vav_foods_admin_app/Data/services/categories_services.dart';
import '../Controllers/all_categories_controller.dart';
import '../Controllers/all_users_controller.dart';
import '../Data/interfaces/users_interfaces.dart';
import '../Data/repository/category_repository.dart';
import '../Data/repository/users_repository.dart';
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
  }
}
