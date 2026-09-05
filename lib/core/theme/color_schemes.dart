import 'package:delmess/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Material 3 Color Schemes for DelMess.
class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainerLight,
    onPrimaryContainer: Color(0xFF1A237E),
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryContainerLight,
    onSecondaryContainer: Color(0xFF004D40),
    tertiary: Color(0xFF6750A4),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEADDFF),
    onTertiaryContainer: Color(0xFF21005D),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: AppColors.surfaceLight,
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Colors.black12,
    scrim: Colors.black,
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: AppColors.primaryDark,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: Color(0xFF1A237E),
    primaryContainer: AppColors.primaryContainerDark,
    onPrimaryContainer: Color(0xFFE8EAF6),
    secondary: AppColors.secondaryDark,
    onSecondary: Color(0xFF00363A),
    secondaryContainer: AppColors.secondaryContainerDark,
    onSecondaryContainer: Color(0xFFE0F7FA),
    tertiary: Color(0xFFD0BCFF),
    onTertiary: Color(0xFF381E72),
    tertiaryContainer: Color(0xFF4F378B),
    onTertiaryContainer: Color(0xFFEADDFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.surfaceDark,
    onSurface: Color(0xFFE6E1E5),
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Colors.black87,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: AppColors.primaryLight,
  );
}
