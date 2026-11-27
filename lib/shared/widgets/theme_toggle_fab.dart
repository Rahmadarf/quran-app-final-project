import 'package:flutter/widgets.dart';

import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Tombol ganti tema mengambang (Dark Mode ↔ Light Mode) yang dapat diakses
/// dari seluruh layar aplikasi.
class FloatingThemeToggle extends StatelessWidget {
  const FloatingThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.maybeOf(context);
    if (theme == null) return const SizedBox.shrink();

    final palette = theme.paletteFor(context);
    final isDark = palette.isDark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      right: 16,
      bottom: 148 + bottomInset,
      child: Pressable(
        onTap: () => theme.toggle(context),
        semanticLabel: isDark ? 'Ganti ke mode terang' : 'Ganti ke mode gelap',
        pressedScale: 0.92,
        child: AppSurface(
          color: palette.surfaceElevated,
          borderColor: palette.borderStrong,
          radius: 999,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shadows: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: AppIcon(
                  isDark ? AppIcons.sun : AppIcons.moon,
                  key: ValueKey(isDark),
                  size: 18,
                  color: palette.accentLight,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isDark ? 'Terang' : 'Gelap',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
