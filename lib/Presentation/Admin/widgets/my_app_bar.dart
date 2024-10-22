import 'package:flutter/material.dart';
import '../../../Constants/colors.dart';
import 'my_text.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  List<Widget>? actions;
  Widget? leading;
  MyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: widget.leading,
      iconTheme: IconThemeData(color: AppColors.background),
      backgroundColor: AppColors.primarygreen,
      centerTitle: true,
      title: MyText(
        text: widget.title,
        color: AppColors.background,
        fontWeight: FontWeight.w500,
      ),
      actions: widget.actions,
    );
  }
}
