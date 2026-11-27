import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';

enum _BadgeKind { pill, tag, status, count, withIcon }

/// Lencana kecil dual-mode: "Jumat", "OFFLINE", "Surah ke-1", jumlah item.
class BadgeChip extends StatelessWidget {
  const BadgeChip._(
    this._kind, {
    super.key,
    required this.label,
    this.textStyle,
    this.icon,
    this.iconColor,
  });

  factory BadgeChip.pill(String label, {Key? key, TextStyle? textStyle}) =>
      BadgeChip._(
        _BadgeKind.pill,
        key: key,
        label: label,
        textStyle: textStyle,
      );

  factory BadgeChip.tag(String label, {Key? key, TextStyle? textStyle}) =>
      BadgeChip._(
        _BadgeKind.tag,
        key: key,
        label: label,
        textStyle: textStyle,
      );

  factory BadgeChip.status(String label, {Key? key}) => BadgeChip._(
        _BadgeKind.status,
        key: key,
        label: label,
      );

  factory BadgeChip.count(String label, {Key? key}) => BadgeChip._(
        _BadgeKind.count,
        key: key,
        label: label,
      );

  factory BadgeChip.withIcon(
    String label,
    AppIcons icon, {
    Key? key,
    Color? iconColor,
  }) =>
      BadgeChip._(
        _BadgeKind.withIcon,
        key: key,
        label: label,
        icon: icon,
        iconColor: iconColor,
      );

  final _BadgeKind _kind;
  final String label;
  final TextStyle? textStyle;
  final AppIcons? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    final Color bg;
    final Color? border;
    final double radius;
    final EdgeInsets padding;
    final TextStyle style;
    final Color effectiveIconColor;

    switch (_kind) {
      case _BadgeKind.pill:
        bg = palette.accentSoft;
        border = palette.borderAccent;
        radius = 999;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 3);
        style = textStyle ??
            AppTextStyles.badge.copyWith(color: palette.accentLight);
        effectiveIconColor = iconColor ?? palette.accentLight;
      case _BadgeKind.tag:
        bg = palette.accentSoft;
        border = null;
        radius = 6;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3);
        style = textStyle ??
            AppTextStyles.micro.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.accentLight,
            );
        effectiveIconColor = iconColor ?? palette.accentLight;
      case _BadgeKind.status:
        bg = palette.accentSoft;
        border = null;
        radius = 6;
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
        style = AppTextStyles.badge.copyWith(
          fontWeight: FontWeight.w700,
          color: palette.accentLight,
        );
        effectiveIconColor = iconColor ?? palette.accentLight;
      case _BadgeKind.count:
        bg = palette.surface;
        border = palette.border;
        radius = 999;
        padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 2);
        style = AppTextStyles.micro.copyWith(color: palette.textMuted);
        effectiveIconColor = iconColor ?? palette.textMuted;
      case _BadgeKind.withIcon:
        bg = palette.accentSoft;
        border = palette.borderAccent;
        radius = 999;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
        style = AppTextStyles.micro.copyWith(color: palette.accentLight);
        effectiveIconColor = iconColor ?? palette.accentLight;
    }

    final text = Text(label, style: style, maxLines: 1);
    return AppSurface(
      color: bg,
      borderColor: border,
      radius: radius,
      padding: padding,
      child: icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(icon!, size: 12, color: effectiveIconColor),
                const SizedBox(width: 6),
                text,
              ],
            ),
    );
  }
}
