import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_surface.dart';
import 'pressable.dart';

class FilterChipItem {
  const FilterChipItem(this.label, {this.count});

  final String label;
  final int? count;
}

enum FilterChipVariant {
  /// Terpilih = latar terang, tulisan gelap tebal (tab Pustaka).
  light,

  /// Terpilih = latar biru aksen (penyaring tafsir).
  accent,
}

/// Baris chip penyaring yang bisa digeser mendatar. Satu chip terpilih.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.variant = FilterChipVariant.light,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<FilterChipItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final FilterChipVariant variant;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _Chip(
              item: items[i],
              selected: i == selectedIndex,
              variant: variant,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.item,
    required this.selected,
    required this.variant,
    required this.onTap,
  });

  final FilterChipItem item;
  final bool selected;
  final FilterChipVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = variant == FilterChipVariant.light;

    final Color background;
    final Color? border;
    final Color foreground;
    final FontWeight weight;
    if (isLight) {
      background = selected ? AppColors.accentLight : AppColors.surface;
      border = null;
      foreground = selected ? AppColors.onLight : AppColors.textMuted;
      weight = selected ? FontWeight.w700 : FontWeight.w500;
    } else {
      background = selected ? AppColors.accent : AppColors.surfaceCard;
      border = selected ? null : AppColors.borderAt(0.4);
      foreground = selected ? AppColors.onAccent : AppColors.skyLabel;
      weight = FontWeight.w500;
    }

    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: item.label,
        child: AppSurface(
          color: background,
          borderColor: border,
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: AppTextStyles.label
                    .copyWith(color: foreground, fontWeight: weight),
              ),
              if (item.count != null) ...[
                const SizedBox(width: 4),
                Opacity(
                  opacity: 0.7,
                  child: Text(
                    '${item.count}',
                    style: AppTextStyles.micro,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
