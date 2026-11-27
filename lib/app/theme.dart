import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilihan mode tema aplikasi (docs/01 §8 #8, 07 §7).
enum AppThemeMode {
  system,
  light,
  dark,
}

/// Palet semantik lengkap sesuai Figma Variables `Quran Audio / Color`
/// untuk mode **Audiophile Obsidian (Dark)** dan **Studio Light (Light)**.
class AppThemePalette {
  const AppThemePalette({
    required this.brightness,
    required this.background,
    required this.backgroundDeep,
    required this.surface,
    required this.surfaceCard,
    required this.surfaceDeep,
    required this.surfaceElevated,
    required this.surfaceActive,
    required this.surfaceStrong,
    required this.accent,
    required this.accentLight,
    required this.accentSoft,
    required this.onAccent,
    required this.textPrimary,
    required this.textTitle,
    required this.textMuted,
    required this.textSubtle,
    required this.textBody,
    required this.placeholder,
    required this.border,
    required this.borderStrong,
    required this.borderAccent,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.scrim,
    required this.shadow,
  });

  final Brightness brightness;
  final Color background;
  final Color backgroundDeep;
  final Color surface;
  final Color surfaceCard;
  final Color surfaceDeep;
  final Color surfaceElevated;
  final Color surfaceActive;
  final Color surfaceStrong;
  final Color accent;
  final Color accentLight;
  final Color accentSoft;
  final Color onAccent;
  final Color textPrimary;
  final Color textTitle;
  final Color textMuted;
  final Color textSubtle;
  final Color textBody;
  final Color placeholder;
  final Color border;
  final Color borderStrong;
  final Color borderAccent;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color scrim;
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  /// Audiophile Obsidian — Dark Mode (Primary).
  static const AppThemePalette dark = AppThemePalette(
    brightness: Brightness.dark,
    background: Color(0xFF0A0B0D),
    backgroundDeep: Color(0xFF060709),
    surface: Color(0xFF131519),
    surfaceCard: Color(0xFF131519),
    surfaceDeep: Color(0xFF131519),
    surfaceElevated: Color(0xFF1C1F26),
    surfaceActive: Color(0x2410B981),
    surfaceStrong: Color(0xFF1C1F26),
    accent: Color(0xFF10B981),
    accentLight: Color(0xFF34D399),
    accentSoft: Color(0x2410B981),
    onAccent: Color(0xFF0A0B0D),
    textPrimary: Color(0xFFF8F9FA),
    textTitle: Color(0xFFF8F9FA),
    textMuted: Color(0xFF8E96A4),
    textSubtle: Color(0xFF6B7280),
    textBody: Color(0xFFCBD2D9),
    placeholder: Color(0xFF6B7280),
    border: Color(0x14FFFFFF),
    borderStrong: Color(0x24FFFFFF),
    borderAccent: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    warningSoft: Color(0x24F59E0B),
    danger: Color(0xFFF43F5E),
    dangerSoft: Color(0x24F43F5E),
    scrim: Color(0xB3000000),
    shadow: Color(0x73000000),
  );

  /// Studio Light — Light Mode (Calibrated neutral scale + WCAG AA accents).
  static const AppThemePalette light = AppThemePalette(
    brightness: Brightness.light,
    background: Color(0xFFF8F9FA),
    backgroundDeep: Color(0xFFF1F3F5),
    surface: Color(0xFFFFFFFF),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceDeep: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF1F3F5),
    surfaceActive: Color(0x1A059669),
    surfaceStrong: Color(0xFFE4E7EC),
    accent: Color(0xFF059669),
    accentLight: Color(0xFF059669),
    accentSoft: Color(0x1A059669),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0A0B0D),
    textTitle: Color(0xFF0A0B0D),
    textMuted: Color(0xFF4B5262),
    textSubtle: Color(0xFF6B7280),
    textBody: Color(0xFF262B34),
    placeholder: Color(0xFF6B7280),
    border: Color(0x140A0B0D),
    borderStrong: Color(0x240A0B0D),
    borderAccent: Color(0xFF059669),
    warning: Color(0xFFB45309),
    warningSoft: Color(0x24F59E0B),
    danger: Color(0xFFE11D48),
    dangerSoft: Color(0x24F43F5E),
    scrim: Color(0x800A0B0D),
    shadow: Color(0x1A0A0B0D),
  );
}

/// Pengendali tema terang/gelap dengan persistensi lokal.
class AppThemeController extends ChangeNotifier {
  AppThemeController({AppThemeMode initialMode = AppThemeMode.dark})
      : _mode = initialMode;

  static const _prefKey = 'quran_audio_theme_mode_v1';

  AppThemeMode _mode;
  AppThemeMode get mode => _mode;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == null) return;
      final parsed = AppThemeMode.values.where((m) => m.name == saved).firstOrNull;
      if (parsed != null && parsed != _mode) {
        _mode = parsed;
        notifyListeners();
      }
    } catch (_) {
      // Abaikan di lingkungan test tanpa SharedPreferences.
    }
  }

  void setMode(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    _persist(mode);
  }

  /// Beralih cepat antara Dark Mode dan Light Mode dari tombol mengambang.
  void toggle(BuildContext context) {
    final current = resolveBrightness(context);
    setMode(current == Brightness.dark ? AppThemeMode.light : AppThemeMode.dark);
  }

  Future<void> _persist(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode.name);
    } catch (_) {}
  }

  Brightness resolveBrightness(BuildContext context) {
    switch (_mode) {
      case AppThemeMode.light:
        return Brightness.light;
      case AppThemeMode.dark:
        return Brightness.dark;
      case AppThemeMode.system:
        return MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.dark;
    }
  }

  AppThemePalette paletteFor(BuildContext context) {
    return resolveBrightness(context) == Brightness.light
        ? AppThemePalette.light
        : AppThemePalette.dark;
  }
}

/// Menyediakan [AppThemeController] ke seluruh pohon widget tanpa bergantung
/// pada MaterialApp.
class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope tidak ditemukan di atas widget ini');
    return scope!.notifier!;
  }

  static AppThemeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppThemeScope>()?.notifier;

  static AppThemePalette paletteOf(BuildContext context) {
    final controller = maybeOf(context);
    if (controller != null) {
      return controller.paletteFor(context);
    }
    final platformBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.dark;
    return platformBrightness == Brightness.light
        ? AppThemePalette.light
        : AppThemePalette.dark;
  }
}
