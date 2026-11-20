import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Gaya teks dari Figma. Antarmuka memakai Plus Jakarta Sans, teks Arab Amiri.
/// Berkas font dibundel di `assets/fonts/` dan dideklarasikan di pubspec.yaml.
abstract final class AppFonts {
  static const String ui = 'PlusJakartaSans';
  static const String arabic = 'Amiri';
}

abstract final class AppTextStyles {
  static TextStyle _ui({
    required double size,
    required double lineHeight,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: AppFonts.ui,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      fontStyle: style,
      color: color,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
    );
  }

  /// Sapaan dan judul rak (17 Bold).
  static TextStyle get heading => _ui(
        size: 17,
        lineHeight: 25.5,
        weight: FontWeight.w700,
        letterSpacing: -0.425,
      );

  /// Judul bagian pada layar Jelajah (18 SemiBold).
  static TextStyle get sectionTitle => _ui(
        size: 18,
        lineHeight: 24,
        weight: FontWeight.w600,
        color: AppColors.textTitle,
      );

  /// Judul kartu kategori dan kartu tafsir (18 Bold).
  static TextStyle get cardHeading => _ui(
        size: 18,
        lineHeight: 24,
        weight: FontWeight.w700,
        color: AppColors.textTitle,
      );

  /// Judul pada kartu media (13 SemiBold).
  static TextStyle get cardTitle => _ui(
        size: 13,
        lineHeight: 16.25,
        weight: FontWeight.w600,
      );

  /// Judul baris daftar (14 Bold).
  static TextStyle get rowTitle => _ui(
        size: 14,
        lineHeight: 20,
        weight: FontWeight.w700,
        letterSpacing: 0.14,
      );

  static TextStyle get body => _ui(
        size: 14,
        lineHeight: 20,
        color: AppColors.textSubtle,
      );

  static TextStyle get bodyRelaxed => _ui(
        size: 14,
        lineHeight: 22.75,
        color: AppColors.textBody,
      );

  static TextStyle get caption => _ui(
        size: 11,
        lineHeight: 16.5,
        color: AppColors.textMuted,
      );

  static TextStyle get captionMedium => _ui(
        size: 11,
        lineHeight: 16.5,
        weight: FontWeight.w500,
      );

  static TextStyle get label => _ui(
        size: 12,
        lineHeight: 16,
        weight: FontWeight.w500,
        color: AppColors.skyLabel,
      );

  static TextStyle get labelStrong => _ui(
        size: 12,
        lineHeight: 16,
        weight: FontWeight.w600,
        color: AppColors.accentLight,
      );

  static TextStyle get micro => _ui(
        size: 10,
        lineHeight: 14,
        weight: FontWeight.w600,
        color: AppColors.skyLabel,
        letterSpacing: 0.4,
      );

  static TextStyle get navLabel => _ui(
        size: 10,
        lineHeight: 15,
        weight: FontWeight.w400,
        color: AppColors.textMuted,
        letterSpacing: -0.25,
      );

  static TextStyle get badge => _ui(
        size: 9,
        lineHeight: 13.5,
        weight: FontWeight.w600,
        color: AppColors.accentLight,
      );

  static TextStyle get hint => _ui(
        size: 14,
        lineHeight: 20,
        color: AppColors.placeholder,
      );

  static TextStyle get quote => _ui(
        size: 13,
        lineHeight: 19.5,
        style: FontStyle.italic,
        color: AppColors.textMuted,
      );

  /// Teks Arab. [size] dan [lineHeight] mengikuti Figma per tempat.
  static TextStyle arabic({
    double size = 22,
    double? lineHeight,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: AppFonts.arabic,
      fontSize: size,
      height: (lineHeight ?? size * 2) / size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
    );
  }

  /// Gaya antarmuka bebas untuk kasus yang tidak tercakup di atas.
  static TextStyle custom({
    required double size,
    required double lineHeight,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
    FontStyle style = FontStyle.normal,
  }) =>
      _ui(
        size: size,
        lineHeight: lineHeight,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
        style: style,
      );
}
