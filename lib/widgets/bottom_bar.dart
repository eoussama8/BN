import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/contants.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.green2,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.elliptical(40,30),
          topRight: Radius.elliptical(40,30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(AppAssets.iconHome, 0),
            _buildNavItem(AppAssets.iconMenu, 1),
            _buildNavItem(AppAssets.iconProfile, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, int index) {
    bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          iconPath,
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            isSelected ? AppColors.white : AppColors.white.withOpacity(0.6),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}