import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/contants.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.greenPastel,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          // ✅ Logo - PNG image
          Image.asset(
            AppAssets.logoPng,
            width: 45,
            height: 45,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 15),

          const _MenuItem(title: "HOW IT WORKS", isActive: true),
          const SizedBox(width: 15),
          const _MenuItem(title: "COMMUNITY"),
          const SizedBox(width: 15),
          const _MenuItem(title: "CONTACT"),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

// ✅ Menu Item widget
class _MenuItem extends StatelessWidget {
  final String title;
  final bool isActive;

  const _MenuItem({
    required this.title,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: isActive ? AppColors.greyDark : AppColors.greyMedium,
        fontSize: 13,
      ),
    );
  }
}