import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Constants/colors.dart';
import '../../../../Constants/responsive.dart';
import '../../../../Controllers/all_products_controller.dart';
import '../../widgets/my_app_bar.dart';

class AddProductsScreen extends StatefulWidget {
  const AddProductsScreen({super.key});

  @override
  State<AddProductsScreen> createState() => _AddProductsScreenState();
}

class _AddProductsScreenState extends State<AddProductsScreen> {
  final AllProductsController allProductsController =
      Get.find<AllProductsController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MyAppBar(
          title: 'Add Products Screen',
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
                        : MediaQuery.of(context).size.width,
              ),
              child: Column(
                children: [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
