import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';

/// Lencana kecil: "Jumat", "OFFLINE", "Surah ke-1", jumlah item.
class BadgeChip extends StatelessWidget {
  const BadgeChip._({
    super.key,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.radius,
    required this.padding,
    required this.textStyle,
    this.icon,
    this.iconColor,
  });

  /// Kapsul bergaris (mis. "Jumat", "QS. Ar-Rahman : 13").
  factory BadgeChip.pill(String label, {Key? key, TextStyle? textStyle}) =>
      BadgeChip._(
        key: key,
        label: label,
        color: AppColors.surfaceStrong,
        borderColor: AppColors.accentAt(0.4),
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        textStyle: textStyle ?? AppTextStyles.badge,
      );

  /// Label persegi kecil (mis. "Surah ke-1", "Ayat Agung").
  factory BadgeChip.tag(String label, {Key? key, TextStyle? textStyle}) =>
      BadgeChip._(
        key: key,
        label: label,
        color: AppColors.accentAt(0.2),
        borderColor: null,
        radius: 4,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        textStyle: textStyle ??
            AppTextStyles.micro.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accentLight,
            ),
      );

  /// Label status tebal (mis. "OFFLINE").
  factory BadgeChip.status(String label, {Key? key}) => BadgeChip._(
        key: key,
        label: label,
        color: AppColors.surfaceStrong,
        borderColor: null,
        radius: 4,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        textStyle: AppTextStyles.badge.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.225,
        ),
      );

  /// Angka penghitung di samping judul (mis. "4").
  factory BadgeChip.count(String label, {Key? key}) => BadgeChip._(
        key: key,
        label: label,
        color: AppColors.surface,
        borderColor: null,
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        textStyle: AppTextStyles.custom(
          size: 11,
          lineHeight: 16.5,
          weight: FontWeight.w600,
          color: AppColors.skyLabel,
        ),
      );

  /// Kapsul dengan ikon di kiri (mis. "14 mnt audio" tanpa latar).
  factory BadgeChip.withIcon(
    String label,
    AppIcons icon, {
    Key? key,
    Color? iconColor,
  }) =>
      BadgeChip._(
        key: key,
        label: label,
        color: AppColors.lightAt(0.15),
        borderColor: AppColors.lightAt(0.4),
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        textStyle: AppTextStyles.micro.copyWith(color: AppColors.accentLight),
        icon: icon,
        iconColor: iconColor ?? AppColors.accentLight,
      );

  final String label;
  final Color color;
  final Color? borderColor;
  final double radius;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final AppIcons? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, style: textStyle, maxLines: 1);
    return AppSurface(
      color: color,
      borderColor: borderColor,
      radius: radius,
      padding: padding,
      child: icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(icon!, size: 12, color: iconColor!),
                const SizedBox(width: 6),
                text,
              ],
            ),
    );
  }
}
