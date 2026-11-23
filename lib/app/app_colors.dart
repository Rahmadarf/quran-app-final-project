import 'dart:ui';

/// Palet "Ocean Blue" dari Figma (section Final Project).
///
/// Figma tidak memakai variabel untuk layar-layar ini, jadi nilai di sini
/// diambil langsung dari hex/rgba pada desain.
abstract final class AppColors {
  // Latar
  static const Color background = Color(0xFF001233);
  static const Color backgroundDeep = Color(0xFF000D29);

  // Permukaan
  static const Color surface = Color(0xFF0F2854);
  static const Color surfaceCard = Color(0xFF102442);
  static const Color surfaceDeep = Color(0xFF071A38);
  static const Color surfaceVerse = Color(0xD9051838); // rgba(5,24,56,0.85)
  static const Color surfaceActive = Color(0xFF142E54);
  static const Color surfaceStrong = Color(0xFF1C4D8D);

  // Aksen
  static const Color accent = Color(0xFF4988C4);
  static const Color accentLight = Color(0xFFBDE8F5);
  static const Color skyLabel = Color(0xFF9BCAFF);

  // Teks
  static const Color textPrimary = Color(0xFFFCFEFF);
  static const Color textTitle = Color(0xFFD2E7DF);
  static const Color textPlayerTitle = Color(0xFFD9E2FF);
  static const Color textMuted = Color(0xFFB8CBE6);
  static const Color textSubtle = Color(0xFFA2B4D2);
  static const Color textFaint = Color(0xFF94A9C9);
  static const Color textBody = Color(0xFFC0C8CA);
  static const Color placeholder = Color(0xFF6B829E);
  static const Color onLight = Color(0xFF001233);
  static const Color onAccent = Color(0xFF091424);

  // Garis dan bayangan
  static const Color border = Color(0xFF1C4D8D);
  static Color borderAt(double opacity) => border.withValues(alpha: opacity);
  static Color accentAt(double opacity) => accent.withValues(alpha: opacity);
  static Color lightAt(double opacity) => accentLight.withValues(alpha: opacity);
  static Color backgroundAt(double opacity) =>
      background.withValues(alpha: opacity);
  static Color surfaceAt(double opacity) => surface.withValues(alpha: opacity);

  static const Color shadow = Color(0x1A000000); // rgba(0,0,0,0.1)

  // Panel pemilih (bottom sheet) dan kartu pemilih, frame Figma "Pilih ...".
  // Paletnya sedikit berbeda dari layar lain (teks krem, abu kebiruan).
  static const Color sheet = Color(0xFF091424);
  static const Color scrim = Color(0x99061810); // rgba(6,24,16,0.6)
  static const Color sheetText = Color(0xFFF4F3E8);
  static const Color sheetMuted = Color(0xFFB8CCC2);
  static const Color sheetIcon = Color(0xFF88ADC3);
  static const Color numberBadge = Color(0xFF284374);
}
