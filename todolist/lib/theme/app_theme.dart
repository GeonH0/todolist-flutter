// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  // 기본 (라이트) 모드 색상
  static const Color primaryLight = Color(0xFF00BFA5); // 주요 강조색
  static const Color backgroundLight = Color(0xFFF5F5F5); // 배경
  static const Color surfaceLight = Color(0xFFFFFFFF); // 카드·시트 배경

  // 다크 모드 색상
  static const Color primaryDark = Color(0xFF00BFA5);
  static const Color backgroundDark = Color(0xFF212121);
  static const Color surfaceDark = Color(0xFF424242);

  // 공통
  static const Color errorColor = Color(0xFFB00020);
}

/// 전역적으로 사용할 텍스트 스타일 모음
class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
  );
}

/// 라이트 테마 정의
final ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryLight,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    onPrimary: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black,
    error: AppColors.errorColor,
  ),

  // AppBar 기본 스타일
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),

  // Scaffold 배경
  scaffoldBackgroundColor: AppColors.backgroundLight,

  // FAB 스타일
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
  ),

  // InputDecoration (TextField) 기본 스타일
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFE0E0E0),
    hintStyle: const TextStyle(color: Colors.black54),
    prefixIconColor: Colors.black54,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),

  // Chip 기본 스타일
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFEEEEEE),
    selectedColor: AppColors.primaryLight,
    secondarySelectedColor: AppColors.primaryLight,
    labelStyle: const TextStyle(color: Colors.black),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),

  // 기타: 텍스트 테마 정의
  textTheme: const TextTheme(
    headlineSmall: AppTextStyles.headline,
    titleMedium: AppTextStyles.subtitle,
    bodyLarge: AppTextStyles.body,
  ),
);

/// 다크 테마 정의
final ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryDark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    onPrimary: Colors.white,
    onBackground: Colors.white70,
    onSurface: Colors.white,
    error: AppColors.errorColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF424242),
    hintStyle: const TextStyle(color: Colors.white54),
    prefixIconColor: Colors.white54,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF616161),
    selectedColor: AppColors.primaryDark,
    secondarySelectedColor: AppColors.primaryDark,
    labelStyle: const TextStyle(color: Colors.white),
    secondaryLabelStyle: const TextStyle(color: Colors.black),
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  textTheme: const TextTheme(
    headlineSmall: AppTextStyles.headline,
    titleMedium: AppTextStyles.subtitle,
    bodyLarge: AppTextStyles.body,
  ),
);
