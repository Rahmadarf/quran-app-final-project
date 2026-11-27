import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Warna sebuah [PillButton].
class PillButtonStyle {
  const PillButtonStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color? border;
  final Color foreground;

  static final action = PillButtonStyle(
    background: AppColors.surface,
    border: AppColors.border,
    foreground: AppColors.accentLight,
  );

  static final toolbar = PillButtonStyle(
    background: AppColors.surfaceStrong,
    border: AppColors.border,
    foreground: AppColors.textPrimary,
  );

  static final highlight = PillButtonStyle(
    background: AppColors.surfaceActive,
    border: AppColors.accent,
    foreground: AppColors.accentLight,
  );
}

/// Tombol kapsul dual-mode dengan ikon di kiri/kanan dan label.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.style,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.iconSize = 13,
    this.textStyle,
  }) : assert(label != null || leadingIcon != null || trailing != null);

  final String? label;
  final AppIcons? leadingIcon;
  final AppIcons? trailingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final PillButtonStyle? style;
  final double? height;
  final EdgeInsets padding;
  final double iconSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final PillButtonStyle s;
    if (style == null || identical(style, PillButtonStyle.action)) {
      s = PillButtonStyle(
        background: palette.surface,
        border: palette.border,
        foreground: palette.accentLight,
      );
    } else if (identical(style, PillButtonStyle.toolbar)) {
      s = PillButtonStyle(
        background: palette.surfaceElevated,
        border: palette.border,
        foreground: palette.textPrimary,
      );
    } else if (identical(style, PillButtonStyle.highlight)) {
      s = PillButtonStyle(
        background: palette.accentSoft,
        border: palette.borderAccent,
        foreground: palette.accentLight,
      );
    } else {
      s = style!;
    }

    final children = <Widget>[
      if (leadingIcon != null) ...[
        AppIcon(leadingIcon!, size: iconSize, color: s.foreground),
        if (label != null) const SizedBox(width: 6),
      ],
      if (label != null)
        Flexible(
          child: Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (textStyle ?? AppTextStyles.label)
                .copyWith(color: s.foreground),
          ),
        ),
      if (trailingIcon != null) ...[
        const SizedBox(width: 6),
        AppIcon(trailingIcon!, size: iconSize - 2, color: s.foreground),
      ],
      if (trailing != null) ...[const SizedBox(width: 6), trailing!],
    ];

    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel ?? label,
      child: AppSurface(
        color: s.background,
        borderColor: s.border,
        radius: 999,
        height: height,
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
