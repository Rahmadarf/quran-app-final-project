import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Membuka panel bawah kustom dual-mode di atas halaman saat ini.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  String? footerHint,
  required Widget Function(BuildContext context, void Function([T? result]) close)
      builder,
}) {
  final palette = AppThemeScope.paletteOf(context);
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: palette.scrim,
      barrierLabel: 'Tutup panel',
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondary) {
        return AppBottomSheet<T>(
          title: title,
          subtitle: subtitle,
          footerHint: footerHint,
          child: Builder(
            builder: (context) => builder(
              context,
              ([T? result]) => Navigator.of(context).pop(result),
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.12), end: Offset.zero)
                .animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// Panel bawah dual-mode yang terpadu dengan palet Audiophile Obsidian / Studio Light.
class AppBottomSheet<T> extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footerHint,
    this.maxHeightFactor = 0.8,
  });

  final String title;
  final String? subtitle;
  final String? footerHint;
  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final palette = AppThemeScope.paletteOf(context);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + media.padding.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: media.size.height * maxHeightFactor,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: AppSurface(
                color: palette.surface,
                borderColor: palette.borderStrong,
                radius: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: palette.borderStrong,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      title,
                                      style: AppTextStyles.heading.copyWith(
                                        fontSize: 20,
                                        color: palette.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (subtitle != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        subtitle!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption.copyWith(
                                          color: palette.textMuted,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SheetCloseButton(
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: child,
                      ),
                    ),
                    if (footerHint != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Text(
                          footerHint!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol tutup 40 dp dual-mode bergambar tanda silang.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Tutup',
      child: AppSurface(
        color: palette.surfaceElevated,
        borderColor: palette.border,
        radius: 999,
        width: 40,
        height: 40,
        child: Center(
          child: CustomPaint(
            size: const Size(10, 10),
            painter: _CrossPainter(palette.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CrossPainter old) => old.color != color;
}
