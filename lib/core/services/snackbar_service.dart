import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class SnackbarService {
  SnackbarService._();

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.snackbarError, Icons.error_outline);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.snackbarInfo, Icons.info_outline);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.snackbarSuccess, Icons.check_circle_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: AppColors.snackbarText, size: AppSizes.iconMd),
              const SizedBox(width: AppSizes.paddingMd),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.snackbarText,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          margin: const EdgeInsets.all(AppSizes.paddingLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLg,
            vertical: AppSizes.paddingMd,
          ),
          duration: AppSizes.snackbarDuration,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }
}
