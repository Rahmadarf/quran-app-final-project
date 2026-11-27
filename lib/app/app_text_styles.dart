import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Gaya teks dari Figma Redesign v2 (Audiophile Obsidian).
/// Antarmuka memakai Plus Jakarta Sans, teks Arab memakai Amiri.
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
    bool tabular = false,
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
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  /// Judul layar utama (24 Bold, -2% tracking).
  static TextStyle get display => _ui(
        size: 24,
        lineHeight: 30,
        weight: FontWeight.w700,
        letterSpacing: -0.48,
      );

  /// Sapaan dan judul rak (18 Bold, -1.5% tracking).
  static TextStyle get heading => _ui(
        size: 18,
        lineHeight: 24,
        weight: FontWeight.w700,
        letterSpacing: -0.27,
      );

  /// Judul bagian pada layar Jelajah (18 Bold).
  static TextStyle get sectionTitle => heading;

  /// Judul kartu kategori dan tafsir (15 SemiBold).
  static TextStyle get cardHeading => _ui(
        size: 15,
        lineHeight: 20,
        weight: FontWeight.w600,
        letterSpacing: -0.08,
      );

  /// Judul pada kartu media & baris daftar (15 SemiBold).
  static TextStyle get cardTitle => _ui(
        size: 15,
        lineHeight: 20,
        weight: FontWeight.w600,
        letterSpacing: -0.08,
      );

  /// Judul baris daftar (15 SemiBold).
  static TextStyle get rowTitle => cardTitle;

  static TextStyle get body => _ui(
        size: 14,
        lineHeight: 21,
        color: AppColors.textMuted,
      );

  static TextStyle get bodyRelaxed => _ui(
        size: 14,
        lineHeight: 22,
        color: AppColors.textBody,
      );

  static TextStyle get caption => _ui(
        size: 12,
        lineHeight: 16,
        color: AppColors.textMuted,
        letterSpacing: 0.18,
        tabular: true,
      );

  static TextStyle get captionMedium => _ui(
        size: 12,
        lineHeight: 16,
        weight: FontWeight.w500,
        letterSpacing: 0.18,
      );

  static TextStyle get label => _ui(
        size: 12,
        lineHeight: 16,
        weight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.18,
        tabular: true,
      );

  static TextStyle get labelStrong => _ui(
        size: 12,
        lineHeight: 16,
        weight: FontWeight.w600,
        color: AppColors.accentLight,
        letterSpacing: 0.18,
      );

  /// Overline / ALL CAPS (10 SemiBold, +8% tracking).
  static TextStyle get micro => _ui(
        size: 10,
        lineHeight: 14,
        weight: FontWeight.w600,
        color: AppColors.accentLight,
        letterSpacing: 0.8,
        tabular: true,
      );

  static TextStyle get navLabel => _ui(
        size: 10,
        lineHeight: 14,
        weight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.6,
      );

  static TextStyle get badge => _ui(
        size: 10,
        lineHeight: 14,
        weight: FontWeight.w600,
        color: AppColors.accentLight,
        letterSpacing: 0.6,
      );

  static TextStyle get hint => _ui(
        size: 14,
        lineHeight: 21,
        color: AppColors.placeholder,
      );

  static TextStyle get quote => _ui(
        size: 14,
        lineHeight: 21,
        color: AppColors.textPrimary,
      );

  /// Teks Arab dengan line-height lega agar tanda baca tidak bertumpuk.
  static TextStyle arabic({
    double size = 26,
    double? lineHeight,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: AppFonts.arabic,
      fontSize: size,
      height: (lineHeight ?? size * 2.15) / size,
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
    bool tabular = false,
  }) =>
      _ui(
        size: size,
        lineHeight: lineHeight,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
        style: style,
        tabular: tabular,
      );
}
