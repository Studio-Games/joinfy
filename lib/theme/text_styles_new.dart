import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  const AppTextStyles._(); // evita instanciar

  // ============= CodePro (Família Principal) =============
  
  // Light (300)
  static const TextStyle light = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  // Regular (400)
  static const TextStyle body = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Bold (700)
  static const TextStyle bold = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  // Black (900)
  static const TextStyle black = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.textSecondary,
  );

  // Small variants
  static const TextStyle small = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle smallLight = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  static const TextStyle smallBold = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static const TextStyle smallBlack = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: AppColors.textSecondary,
  );

  // ============= CodeProLC (Variante Display) =============
  
  // LightLC (100)
  static const TextStyle lightLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 14,
    fontWeight: FontWeight.w100,
    color: AppColors.textSecondary,
  );

  // Regular LC (200)
  static const TextStyle bodyLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 14,
    fontWeight: FontWeight.w200,
    color: AppColors.textSecondary,
  );

  // Bold LC (400)
  static const TextStyle boldLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Black LC (900)
  static const TextStyle blackLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.textSecondary,
  );

  // Heading variants with LC
  static const TextStyle headingLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 30,
    fontWeight: FontWeight.w200,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingBoldLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingBlackLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // Large text variants (18px)
  static const TextStyle large = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle largeLight = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  static const TextStyle largeBold = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static const TextStyle largeBlack = TextStyle(
    fontFamily: 'CodePro',
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: AppColors.textSecondary,
  );

  // Large LC variants (18px)
  static const TextStyle largeLightLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 18,
    fontWeight: FontWeight.w100,
    color: AppColors.textSecondary,
  );

  static const TextStyle largeLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 18,
    fontWeight: FontWeight.w200,
    color: AppColors.textSecondary,
  );

  static const TextStyle largeBoldLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle largeBlackLC = TextStyle(
    fontFamily: 'CodeProLC',
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: AppColors.textSecondary,
  );

  // ============= Helper methods for custom sizes =============
  
  /// Retorna um TextStyle CodePro com tamanho e weight customizados
  static TextStyle codePro({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
  }) {
    return TextStyle(
      fontFamily: 'CodePro',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Retorna um TextStyle CodeProLC com tamanho e weight customizados
  static TextStyle codeProLC({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w200,
    Color color = AppColors.textSecondary,
  }) {
    return TextStyle(
      fontFamily: 'CodeProLC',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
