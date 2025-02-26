import 'package:flutter/material.dart';
import 'package:weave_it/core/theme/app_colours.dart';
import 'package:weave_it/core/theme/app_textstyles.dart';

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      brightness: Brightness.light,
      textTheme: TextTheme(
        bodySmall: AppTextStyles.bodySmall,
        bodyMedium: AppTextStyles.bodyMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        headlineSmall: AppTextStyles.headlineSmall,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineLarge: AppTextStyles.headlineLarge,
      ), // TextTheme
      colorScheme: const ColorScheme(
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        secondary: AppColors.secondary,
        onSecondary: AppColors.background,
        error: AppColors.errorColor,
        onError: AppColors.surface,
        surface: AppColors.background,
        onSurface: AppColors.textColor,
        brightness: Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
          textStyle: AppTextStyles.button,
        ), // ElevatedButtonThemeData
      ),
    );
    // ColorScheme, ThemeData
  }
}
