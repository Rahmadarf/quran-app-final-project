import 'dart:ui';

/// Palet Audiophile Obsidian (Dark primary) sesuai desain Figma Redesign v2.
///
/// Nilai statis di sini adalah nilai bawaan Dark Mode agar widget yang tidak
/// menerima konteks tetap aman. Untuk dukungan penuh Dark & Light Mode,
/// gunakan `AppThemeScope.paletteOf(context)`.
abstract final class AppColors {
  // Latar (Obsidian Dark)
  static const Color background = Color(0xFF0A0B0D);
  static const Color backgroundDeep = Color(0xFF060709);

  // Permukaan
  static const Color surface = Color(0xFF131519);
  static const Color surfaceCard = Color(0xFF131519);
  static const Color surfaceDeep = Color(0xFF131519);
  static const Color surfaceVerse = Color(0xFF0A0B0D);
  static const Color surfaceActive = Color(0x2410B981); // emerald 14% tint
  static const Color surfaceStrong = Color(0xFF1C1F26);

  // Aksen (Single Emerald)
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);
  static const Color skyLabel = Color(0xFF34D399);

  // Teks
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textTitle = Color(0xFFF8F9FA);
  static const Color textPlayerTitle = Color(0xFFF8F9FA);
  static const Color textMuted = Color(0xFF8E96A4);
  static const Color textSubtle = Color(0xFF8E96A4);
  static const Color textFaint = Color(0xFF6B7280);
  static const Color textBody = Color(0xFFCBD2D9);
  static const Color placeholder = Color(0xFF6B7280);
  static const Color onLight = Color(0xFF0A0B0D);
  static const Color onAccent = Color(0xFF0A0B0D);

  // Status
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0x24F59E0B);
  static const Color danger = Color(0xFFF43F5E);
  static const Color dangerSoft = Color(0x24F43F5E);

  // Garis dan bayangan
  static const Color border = Color(0x14FFFFFF); // white 8%
  static const Color borderStrong = Color(0x24FFFFFF); // white 14%
  static Color borderAt(double opacity) =>
      const Color(0xFFFFFFFF).withValues(alpha: (opacity * 0.16).clamp(0, 1));
  static Color accentAt(double opacity) => accent.withValues(alpha: opacity);
  static Color lightAt(double opacity) => accentLight.withValues(alpha: opacity);
  static Color backgroundAt(double opacity) =>
      background.withValues(alpha: opacity);
  static Color surfaceAt(double opacity) => surface.withValues(alpha: opacity);

  static const Color shadow = Color(0x73000000);

  // Panel bawah (terpadu dengan permukaan utama, tidak lagi terpisah)
  static const Color sheet = Color(0xFF131519);
  static const Color scrim = Color(0xB3000000);
  static const Color sheetText = Color(0xFFF8F9FA);
  static const Color sheetMuted = Color(0xFF8E96A4);
  static const Color sheetIcon = Color(0xFF8E96A4);
  static const Color numberBadge = Color(0xFF1C1F26);
}
