import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'badge_chip.dart';
import 'pressable.dart';

/// Judul bagian dual-mode dengan aksi "Lihat semua" di kanan.
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
  final String? trailingNote;
  final VoidCallback? onTrailingTap;
  final VoidCallback? onChevronTap;
  final bool accentBar;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final style = (titleStyle ?? AppTextStyles.heading)
        .copyWith(color: palette.textPrimary);

    Widget? trailing;
    if (trailingLabel != null || onChevronTap != null) {
      final label = trailingLabel ?? 'Lihat semua';
      trailing = Pressable(
        onTap: onTrailingTap ?? onChevronTap,
        semanticLabel: label,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelStrong
                  .copyWith(color: palette.accentLight),
            ),
            const SizedBox(width: 4),
            AppIcon(
              AppIcons.chevronRight,
              size: 10,
              color: palette.accentLight,
            ),
          ],
        ),
      );
    } else if (trailingNote != null) {
      trailing = Text(
        trailingNote!,
        style: AppTextStyles.label.copyWith(color: palette.textMuted),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.caption
                          .copyWith(color: palette.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
