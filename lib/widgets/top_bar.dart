import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/constants.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.greenPastel,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Left: SVG menu icon
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: SvgPicture.asset(
                AppAssets.iconMenu,
                width: 26,
                height: 26,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),

            // ✅ Center: Menu text items
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _MenuItem(title: "HOW IT WORKS", isActive: true),
                SizedBox(width: 18),
                _MenuItem(title: "COMMUNITY"),
              ],
            ),

            // ✅ Right: Logo
            Image.asset(
              AppAssets.logoPng,
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

// ✅ Menu item widget
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
