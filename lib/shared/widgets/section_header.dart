import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'badge_chip.dart';
import 'icon_circle_button.dart';
import 'pressable.dart';

/// Judul bagian dengan aksi "Lihat semua" di kanan.
///
/// - [accentBar]: garis biru kecil di kiri judul (layar Jelajah).
/// - [count]: angka penghitung di samping judul (layar Pustaka).
/// - [trailingLabel]: teks aksi dengan panah; tanpa itu dan bila
///   [onChevronTap] diisi, tampil tombol panah bulat (Beranda).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.count,
    this.trailingLabel,
    this.trailingNote,
    this.onTrailingTap,
    this.onChevronTap,
    this.accentBar = false,
    this.titleStyle,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;
  final int? count;
  final String? trailingLabel;

  /// Keterangan polos di kanan tanpa panah dan tanpa aksi (mis. "6 Kategori").
  final String? trailingNote;
  final VoidCallback? onTrailingTap;
  final VoidCallback? onChevronTap;
  final bool accentBar;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final style = titleStyle ??
        (accentBar ? AppTextStyles.sectionTitle : AppTextStyles.heading);

    Widget? trailing;
    if (trailingLabel != null) {
      trailing = Pressable(
        onTap: onTrailingTap,
        semanticLabel: trailingLabel,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailingLabel!, style: AppTextStyles.labelStrong),
            const SizedBox(width: 2),
            const AppIcon(
              AppIcons.chevronRight,
              size: 8,
              color: AppColors.accentLight,
            ),
          ],
        ),
      );
    } else if (trailingNote != null) {
      trailing = Text(
        trailingNote!,
        style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
      );
    } else if (onChevronTap != null) {
      trailing = IconCircleButton(
        icon: AppIcons.chevronRight,
        semanticLabel: 'Lihat semua $title',
        size: 28,
        iconSize: 10,
        iconColor: AppColors.textMuted,
        onTap: onChevronTap,
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (accentBar) ...[
            const SizedBox(
              width: 6,
              height: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Semantics(
                        header: true,
                        child: Text(title, style: style),
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 8),
                      BadgeChip.count('$count'),
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.label),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
