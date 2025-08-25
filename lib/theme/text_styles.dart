import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  const AppTextStyles._(); // evita instanciar

  // Títulos usando a variante LC (mais “display”)
  static const TextStyle headingLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, // precisa ser const no AppColors
  );

  static const TextStyle bodyLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle boldLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // Corpo usando a família normal
  static const TextStyle body = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 12, // menor que body
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
