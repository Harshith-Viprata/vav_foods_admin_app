import 'package:flutter/material.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_app_bar.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_drawer.dart';
import 'package:vav_foods_admin_app/Presentation/Admin/widgets/my_text.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const MyDrawer(),
        appBar: MyAppBar(title: 'Main Screen'),
        body: SingleChildScrollView(
          child: MyText(text: 'MainScreen'),
        ),
      ),
    );
  }
}
