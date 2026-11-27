import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Pilihan mode tema aplikasi (docs/01 §8 #8, 07 §7).
enum AppThemeMode {
  system,
  light,
  dark,
}

/// Palet warna aktif untuk mode gelap dan mode terang.
class AppThemePalette {
  const AppThemePalette({
    required this.brightness,
    required this.background,
    required this.backgroundDeep,
    required this.surface,
    required this.surfaceCard,
    required this.surfaceDeep,
    required this.surfaceActive,
    required this.surfaceStrong,
    required this.accent,
    required this.accentLight,
    required this.textPrimary,
    required this.textTitle,
    required this.textMuted,
    required this.textSubtle,
    required this.textBody,
    required this.border,
  });

  final Brightness brightness;
  final Color background;
  final Color backgroundDeep;
  final Color surface;
  final Color surfaceCard;
  final Color surfaceDeep;
  final Color surfaceActive;
  final Color surfaceStrong;
  final Color accent;
  final Color accentLight;
  final Color textPrimary;
  final Color textTitle;
  final Color textMuted;
  final Color textSubtle;
  final Color textBody;
  final Color border;

  bool get isDark => brightness == Brightness.dark;

  static const AppThemePalette dark = AppThemePalette(
    brightness: Brightness.dark,
    background: AppColors.background,
    backgroundDeep: AppColors.backgroundDeep,
    surface: AppColors.surface,
    surfaceCard: AppColors.surfaceCard,
    surfaceDeep: AppColors.surfaceDeep,
    surfaceActive: AppColors.surfaceActive,
    surfaceStrong: AppColors.surfaceStrong,
    accent: AppColors.accent,
    accentLight: AppColors.accentLight,
    textPrimary: AppColors.textPrimary,
    textTitle: AppColors.textTitle,
    textMuted: AppColors.textMuted,
    textSubtle: AppColors.textSubtle,
    textBody: AppColors.textBody,
    border: AppColors.border,
  );

  static const AppThemePalette light = AppThemePalette(
    brightness: Brightness.light,
    background: Color(0xFFF4F8FC),
    backgroundDeep: Color(0xFFEAF1F8),
    surface: Color(0xFFFFFFFF),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceDeep: Color(0xFFEBF2FA),
    surfaceActive: Color(0xFFDCEBFA),
    surfaceStrong: Color(0xFFBFD7F0),
    accent: Color(0xFF1E60A6),
    accentLight: Color(0xFF144880),
    textPrimary: Color(0xFF0A1E38),
    textTitle: Color(0xFF0D2847),
    textMuted: Color(0xFF425B78),
    textSubtle: Color(0xFF566E8A),
    textBody: Color(0xFF1D344D),
    border: Color(0xFFC4D7EA),
  );
}

/// Pengendali tema terang/gelap yang mengikuti sistem secara bawaan.
class AppThemeController extends ChangeNotifier {
  AppThemeController({AppThemeMode initialMode = AppThemeMode.system})
      : _mode = initialMode;

  AppThemeMode _mode;
  AppThemeMode get mode => _mode;

  void setMode(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
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
