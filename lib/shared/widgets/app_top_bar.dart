import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import 'app_surface.dart';

/// Bilah atas kaca dengan tiga slot: [leading], [center], [trailing].
///
/// Dipakai semua header: sapaan Beranda, Jelajah, Pustaka, Reader, dan
/// Fullscreen Player. Tinggi isi 64 dp di luar area aman atas.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.leading,
    this.center,
    this.trailing,
    this.centered = false,
    this.background,
    this.showBottomBorder = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  final Widget? leading;
  final Widget? center;
  final Widget? trailing;

  /// `true` = [center] di tengah (Fullscreen Player); `false` = rata kiri
  /// setelah [leading] dan mengisi sisa ruang.
  final bool centered;
  final Color? background;
  final bool showBottomBorder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    final Widget row;
    if (centered) {
      row = Stack(
        alignment: Alignment.center,
        children: [
          if (center != null) Center(child: center),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [leading ?? const SizedBox.shrink(), ?trailing],
          ),
        ],
      );
    } else {
      row = Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(child: center ?? const SizedBox.shrink()),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      );
    }

    return AppSurface(
      color: background ?? AppColors.backgroundAt(0.9),
      blur: 24,
      radius: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showBottomBorder
              ? Border(bottom: BorderSide(color: AppColors.borderAt(0.4)))
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: Padding(padding: padding, child: row),
        ),
      ),
    );
  }
}
