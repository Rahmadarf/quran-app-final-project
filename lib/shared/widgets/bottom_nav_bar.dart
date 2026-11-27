import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'pressable.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Bilah navigasi bawah 4 tab dual-mode (Beranda, Al-Qur'an, Jelajah, Pustaka)
/// menggunakan Phosphor Icons.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  });

  /// Empat tab bawaan sesuai Figma Redesign v2.
  static const defaultItems = [
    BottomNavItem(
      label: 'Beranda',
      icon: PhosphorIconsRegular.house,
      activeIcon: PhosphorIconsFill.house,
    ),
    BottomNavItem(
      label: "Al-Qur'an",
      icon: PhosphorIconsRegular.bookOpenText,
      activeIcon: PhosphorIconsFill.bookOpenText,
    ),
    BottomNavItem(
      label: 'Jelajah',
      icon: PhosphorIconsRegular.compass,
      activeIcon: PhosphorIconsFill.compass,
    ),
    BottomNavItem(
      label: 'Pustaka',
      icon: PhosphorIconsRegular.books,
      activeIcon: PhosphorIconsFill.books,
    ),
  ];

  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final palette = AppThemeScope.paletteOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    palette: palette,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool selected;
  final AppThemePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? palette.accentLight : palette.textMuted;
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: item.label,
        pressedScale: 0.94,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
              child: Center(
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
