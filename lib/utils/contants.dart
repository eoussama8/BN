import 'package:flutter/material.dart';

class AppAssets {
  static const String logoPng = 'assets/images/logo.png';
}

class AppColors {
  // Main colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyDark = Color(0xFF33363F);
  static const Color greyMedium = Color(0xFF757575);
  static const Color greyMedium70 = Color(0xB2757575); // 70% opacity
  static const Color greenPastel = Color(0xFFE1EDD2);
  static const Color greenDark = Color(0xFF67815A);
  static const Color green1 = Color(0xFF97A087);
  static const Color green2 = Color(0xFF8CA87D);

  // Additional colors
  static const Color red = Color(0xFFFB4447);
  static const Color red50 = Color(0x80FB4447); // 50% opacity
  static const Color greenBright = Color(0xFF49DA70);
  static const Color greenBright55 = Color(0x8C49DA70); // 55% opacity

  // Text colors
  static const Color textGrey = Color(0xFF434343);
  static const Color textGreen = Color(0xFF67815A);
  static const Color black = Color(0xFF000000);

  // Icon colors (can reuse main colors or define new ones)
  static const Color iconGrey = greyMedium;
  static const Color iconGreen = greenDark;
  static const Color iconRed = red;
}
