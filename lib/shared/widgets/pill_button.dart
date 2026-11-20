import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
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

  /// Aksi ayat: "Tafsir", "Ulang 3x".
  static final action = PillButtonStyle(
    background: AppColors.surface,
    border: AppColors.borderAt(0.6),
    foreground: AppColors.accentLight,
  );

  /// Pemilih di kartu surat: "Misyari Rasyid ⌄", "ABC".
  static final toolbar = PillButtonStyle(
    background: AppColors.backgroundAt(0.7),
    border: AppColors.borderAt(0.4),
    foreground: AppColors.textPlayerTitle,
  );

  /// Tombol "Mushaf" di header Fullscreen Player.
  static final highlight = PillButtonStyle(
    background: AppColors.lightAt(0.15),
    border: AppColors.lightAt(0.4),
    foreground: AppColors.accentLight,
  );
}

/// Tombol kapsul dengan ikon di kiri/kanan dan label.
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
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.iconSize = 12,
    this.textStyle,
  }) : assert(label != null || leadingIcon != null || trailing != null);

  final String? label;
  final AppIcons? leadingIcon;
  final AppIcons? trailingIcon;

  /// Widget bebas di ujung kanan (mis. titik "aktif" pada tombol ABC).
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
    final s = style ?? PillButtonStyle.action;
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
            style: (textStyle ?? AppTextStyles.micro)
                .copyWith(color: s.foreground, letterSpacing: 0.25),
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
