import 'package:flutter/material.dart';
import 'package:soen_390/styles/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("My Calendar"),
      foregroundColor: appTheme.colorScheme.onPrimary,
      backgroundColor: appTheme.primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
