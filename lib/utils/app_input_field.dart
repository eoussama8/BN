import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'contants.dart';

class AppInputField extends StatelessWidget {
  final String hintText;
  final bool obscureText;

  const AppInputField({
    required this.hintText,
    this.obscureText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.subtitle,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyTitle, width: 1.4),
        ),
      ),
    );
  }
}
