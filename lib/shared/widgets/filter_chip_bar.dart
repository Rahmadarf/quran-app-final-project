import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_surface.dart';
import 'pressable.dart';

class FilterChipItem {
  const FilterChipItem(this.label, {this.count});

  final String label;
  final int? count;
}

enum FilterChipVariant {
  light,
  accent,
}

/// Baris chip penyaring dual-mode sesuai Figma `Obsidian / FilterChip`.
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
    required this.onTap,
  });

  final FilterChipItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final background = selected ? palette.accent : palette.surface;
    final border = selected ? null : palette.border;
    final foreground = selected ? palette.onAccent : palette.textMuted;

    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: item.label,
        child: AppSurface(
          color: background,
          borderColor: border,
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: AppTextStyles.label.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (item.count != null) ...[
                const SizedBox(width: 5),
                Text(
                  '${item.count}',
                  style: AppTextStyles.micro.copyWith(
                    color: foreground.withValues(alpha: 0.75),
                    letterSpacing: 0,
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
