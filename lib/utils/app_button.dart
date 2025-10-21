import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'constants.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSmall;
  final bool isSolid;

  const AppButton({
    required this.text,
    required this.onPressed,
    this.isSmall = false,
    this.isSolid = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isSmall ? 36 : 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSolid ? AppColors.greyDark : Colors.transparent,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: isSolid
              ? BorderSide.none
              : const BorderSide(color: AppColors.greyDark, width: 1.2),
        ),
        onPressed: onPressed,
        child: Text(text, style: AppTextStyles.button),
      ),
    );
  }
}
