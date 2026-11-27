import 'package:flutter/widgets.dart';

import '../../app/theme.dart';

/// Bilah atas bersih dual-mode dengan tiga slot: [leading], [center], [trailing].
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.leading,
    this.center,
    this.trailing,
    this.centered = false,
    this.background,
    this.showBottomBorder = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Widget? leading;
  final Widget? center;
  final Widget? trailing;
  final bool centered;
  final Color? background;
  final bool showBottomBorder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final palette = AppThemeScope.paletteOf(context);

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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? palette.background,
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: palette.border))
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: Padding(padding: padding, child: row),
      ),
    );
  }
}
