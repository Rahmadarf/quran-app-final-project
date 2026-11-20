import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pill_button.dart';
import '../../../shared/widgets/pressable.dart';

/// Kartu informasi surat di atas Reader: metadata, nama Arab, nama Latin,
/// arti, lalu bilah alat (qari, transliterasi, ukuran huruf, ulang).
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

  /// Mis. "Surat ke-55 • 78 Ayat • Makkiyah".
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
    return AppSurface(
      color: AppColors.surfaceAt(0.85),
      borderColor: AppColors.border,
      blur: 12,
      radius: 12,
      padding: const EdgeInsets.all(16),
      shadows: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 15,
          offset: Offset(0, 10),
          spreadRadius: -3,
        ),
      ],
      child: Column(
        children: [
          AppSurface(
            color: AppColors.backgroundAt(0.7),
            borderColor: AppColors.borderAt(0.5),
            radius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(
                  AppIcons.mushaf,
                  size: 12,
                  color: AppColors.skyLabel,
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(metadata, style: AppTextStyles.micro)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            arabicName,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.arabic(
              size: 36,
              lineHeight: 58.5,
              color: AppColors.accentLight,
            ),
          ),
          Text(
            latinName,
            style: AppTextStyles.custom(
              size: 18,
              lineHeight: 24,
              weight: FontWeight.w600,
              letterSpacing: -0.45,
            ),
          ),
          Text(
            meaning,
            style: AppTextStyles.custom(
              size: 12,
              lineHeight: 16,
              weight: FontWeight.w500,
              color: AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderAt(0.5)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
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
                      textStyle: AppTextStyles.micro.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      semanticLabel: 'Pilih qari. Saat ini $qariName',
                      onTap: onQariTap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PillButton(
                    label: 'ABC',
                    height: 32,
                    style: PillButtonStyle(
                      background: AppColors.backgroundAt(0.7),
                      border: AppColors.borderAt(0.4),
                      foreground: AppColors.textSubtle,
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
                              ? AppColors.accentLight
                              : AppColors.placeholder,
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
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AppSurface(
        shape: BoxShape.circle,
        color: AppColors.backgroundAt(0.7),
        borderColor: AppColors.borderAt(0.4),
        width: 32,
        height: 32,
        child: Center(
          child: AppIcon(
            icon,
            size: 13,
            color: active ? AppColors.accentLight : AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}
