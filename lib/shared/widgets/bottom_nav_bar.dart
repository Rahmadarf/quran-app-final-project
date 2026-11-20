import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final AppIcons icon;
  final AppIcons activeIcon;
}

/// Bilah navigasi bawah 4 tab dengan latar kaca (Beranda, Quran, Jelajah, Pustaka).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  });

  /// Empat tab bawaan sesuai Figma.
  static const defaultItems = [
    BottomNavItem(
      label: 'Beranda',
      icon: AppIcons.home,
      activeIcon: AppIcons.homeFilled,
    ),
    BottomNavItem(
      label: 'Quran',
      icon: AppIcons.quran,
      activeIcon: AppIcons.quran,
    ),
    BottomNavItem(
      label: 'Jelajah',
      icon: AppIcons.compass,
      activeIcon: AppIcons.compassFilled,
    ),
    BottomNavItem(
      label: 'Pustaka',
      icon: AppIcons.library,
      activeIcon: AppIcons.libraryFilled,
    ),
  ];

  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AppSurface(
      color: AppColors.backgroundAt(0.95),
      blur: 24,
      radius: 0,
      shadows: const [
        BoxShadow(
          color: Color(0xB3000D29), // rgba(0,13,41,0.7)
          blurRadius: 24,
          offset: Offset(0, -4),
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderAt(0.5))),
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
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
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
    required this.onTap,
  });

  final BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accentLight : AppColors.textMuted;
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
              height: 20,
              child: Center(
                child: AppIcon(
                  selected ? item.activeIcon : item.icon,
                  size: 18,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
