import 'package:flutter/material.dart';
import 'constants.dart';

class AppTextStyles {
  static const TextStyle button = TextStyle(
    fontFamily: 'Itim',
    fontSize: 16,
    color: AppColors.greyDark,
  );

  static const TextStyle input = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    color: AppColors.black,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 30,
    color: AppColors.greyTitle,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.greyMedium,
  );

  static const TextStyle paragraph = TextStyle(
    fontFamily: 'Lemon',
    fontSize: 32,
    color: AppColors.white,
  );
}
