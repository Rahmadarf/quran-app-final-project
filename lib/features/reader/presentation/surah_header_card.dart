import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pill_button.dart';
import '../../../shared/widgets/pressable.dart';

/// Kartu informasi surat di atas Reader dual-mode.
class SurahHeaderCard extends StatelessWidget {
  const SurahHeaderCard({
    super.key,
    required this.metadata,
    required this.arabicName,
    required this.latinName,
    required this.meaning,
    required this.qariName,
    this.transliterationOn = true,
    this.repeatOn = false,
    this.onQariTap,
    this.onTransliterationTap,
    this.onTextSizeTap,
    this.onRepeatTap,
  });

  final String metadata;
  final String arabicName;
  final String latinName;
  final String meaning;
  final String qariName;
  final bool transliterationOn;
  final bool repeatOn;
  final VoidCallback? onQariTap;
  final VoidCallback? onTransliterationTap;
  final VoidCallback? onTextSizeTap;
  final VoidCallback? onRepeatTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return AppSurface(
      color: palette.surface,
      borderColor: palette.border,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppSurface(
            color: palette.surfaceElevated,
            borderColor: palette.border,
            radius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  AppIcons.mushaf,
                  size: 12,
                  color: palette.accentLight,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    metadata,
                    style: AppTextStyles.micro.copyWith(
                      color: palette.textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            arabicName,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.arabic(
              size: 34,
              lineHeight: 54,
              color: palette.textPrimary,
            ),
          ),
          Text(
            latinName,
            style: AppTextStyles.heading.copyWith(color: palette.textPrimary),
          ),
          Text(
            meaning,
            style: AppTextStyles.caption.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Flexible(
                    child: PillButton(
                      label: qariName,
                      leadingIcon: AppIcons.qari,
                      trailingIcon: AppIcons.chevronDown,
                      style: PillButtonStyle.toolbar,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: AppTextStyles.label,
                      semanticLabel: 'Pilih qari. Saat ini $qariName',
                      onTap: onQariTap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PillButton(
                    label: 'ABC',
                    height: 32,
                    style: PillButtonStyle(
                      background: palette.surfaceElevated,
                      border: palette.border,
                      foreground: palette.textPrimary,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    semanticLabel: transliterationOn
                        ? 'Transliterasi aktif'
                        : 'Transliterasi mati',
                    trailing: SizedBox(
                      width: 6,
                      height: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: transliterationOn
                              ? palette.accent
                              : palette.textSubtle,
                        ),
                      ),
                    ),
                    onTap: onTransliterationTap,
                  ),
                  const SizedBox(width: 6),
                  _ToolCircle(
                    icon: AppIcons.textSize,
                    label: 'Ukuran huruf',
                    onTap: onTextSizeTap,
                  ),
                  const SizedBox(width: 6),
                  _ToolCircle(
                    icon: AppIcons.repeat,
                    label: repeatOn ? 'Ulang aktif' : 'Ulang mati',
                    active: repeatOn,
                    onTap: onRepeatTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCircle extends StatelessWidget {
  const _ToolCircle({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final AppIcons icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AppSurface(
        shape: BoxShape.circle,
        color: active ? palette.accentSoft : palette.surfaceElevated,
        borderColor: active ? palette.borderAccent : palette.border,
        width: 32,
        height: 32,
        child: Center(
          child: AppIcon(
            icon,
            size: 13,
            color: active ? palette.accentLight : palette.textMuted,
          ),
        ),
      ),
    );
  }
}
