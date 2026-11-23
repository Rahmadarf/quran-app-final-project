import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Membuka panel bawah kustom di atas halaman saat ini.
///
/// [builder] menerima fungsi `close` untuk menutup panel dan mengembalikan
/// nilai ke pemanggil. Mengetuk area gelap di luar panel menutup panel dengan
/// hasil `null`.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  String? footerHint,
  required Widget Function(BuildContext context, void Function([T? result]) close)
      builder,
}) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: AppColors.scrim,
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

/// Panel bawah: gagang, judul, subjudul, tombol tutup, isi yang bisa digulir,
/// dan petunjuk kecil di dasar. Dipakai pemilih qari, surat, dan ayat.
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

  /// Tinggi maksimum panel sebagai bagian dari tinggi layar.
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

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
            // Mengetuk panel tidak boleh menutupnya lewat penghalang.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: AppSurface(
                color: AppColors.sheet,
                borderColor: AppColors.border,
                radius: 22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 9),
                    const Center(
                      child: SizedBox(
                        width: 44,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(19, 13, 21, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      title,
                                      style: AppTextStyles.custom(
                                        size: 22,
                                        lineHeight: 32,
                                        weight: FontWeight.w600,
                                        color: AppColors.sheetText,
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
                                        style: AppTextStyles.custom(
                                          size: 12,
                                          lineHeight: 17,
                                          color: AppColors.sheetMuted,
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
                    const SizedBox(height: 20),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: child,
                      ),
                    ),
                    if (footerHint != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
                        child: Text(
                          footerHint!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.custom(
                            size: 11,
                            lineHeight: 16,
                            color: AppColors.sheetMuted,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 25),
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

/// Tombol tutup 44 dp bergambar tanda silang yang digambar sendiri.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Tutup',
      child: AppSurface(
        color: AppColors.surfaceCard,
        radius: 12,
        width: 44,
        height: 44,
        child: const Center(
          child: CustomPaint(
            size: Size(10, 10),
            painter: _CrossPainter(AppColors.sheetText),
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
