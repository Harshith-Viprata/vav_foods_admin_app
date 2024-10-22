import 'package:get/get.dart';
import '../Presentation/Admin/screens/category_management/add_categories_screen.dart';
import '../Presentation/Admin/screens/category_management/all_categories_screen.dart';
import '../Presentation/Admin/screens/category_management/edit_categories_screen.dart';
import '../Presentation/Admin/screens/category_management/single_category_details_screen.dart';
import '../Presentation/Admin/screens/product_management/add_products_screen.dart';
import '../Presentation/Admin/screens/users_management/add_user_screen.dart';
import '../Presentation/Admin/screens/users_management/all_users_screen.dart';
import '../Presentation/Admin/screens/users_management/edit_user_details_screen.dart';
import '../Presentation/Admin/screens/main_screen.dart';
import '../Presentation/Admin/screens/users_management/single_user_details_screen.dart';

// Define your routes
class AppRoutes {
  static const String mainScreen = '/MainScreen';
  static const String allUsersScreen = '/AllusersScreen';
  static const String singleUserDetailsScreen = '/SingleUserDetailsScreen';
  static const String addUserScreen = '/AddUserScreen';
  static const String editUserDetailsScreen = '/EditUserDetailsScreen';
  static const String allCategoriesScreen = '/AllCategoriesScreen';
  static const String addCategoriesScreen = '/AddCategoriesScreen';
  static const String singleCategoryDetailsScreen =
      '/SingleCategoryDetailsScreen';
  static const String editCategoriesScreen = '/EditCategoriesScreen';

  static const String addProductsScreen = '/AddProductsScreen';

  static final List<GetPage> routes = [
    GetPage(name: mainScreen, page: () => const MainScreen()),
    GetPage(name: allUsersScreen, page: () => const AllUsersScreen()),
    GetPage(
        name: singleUserDetailsScreen, page: () => SingleUserDetailsScreen()),
    GetPage(name: addUserScreen, page: () => const AddUserScreen()),
    GetPage(
        name: editUserDetailsScreen, page: () => const EditUserDetailsScreen()),
    GetPage(name: allCategoriesScreen, page: () => const AllCategoriesScreen()),
    GetPage(name: addCategoriesScreen, page: () => const AddCategoriesScreen()),
    GetPage(
        name: singleCategoryDetailsScreen,
        page: () => const SingleCategoryDetailsScreen()),
    GetPage(name: editCategoriesScreen, page: () => EditCategoryScreen()),
    GetPage(name: addProductsScreen, page: () => const AddProductsScreen()),
  ];
}
