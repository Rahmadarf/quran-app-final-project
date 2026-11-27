import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/equalizer_bars.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pill_button.dart';

/// Kartu satu ayat di Reader dual-mode sesuai Figma `Obsidian / AyahTile`.
class AyahTile extends StatelessWidget {
  const AyahTile({
    super.key,
    required this.number,
    required this.arabic,
    required this.translation,
    this.transliteration,
    this.active = false,
    this.playing = false,
    this.bookmarked = false,
    this.playbackLabel,
    this.repeatLabel,
    this.arabicFontSize = 26,
    this.onPlay,
    this.onBookmark,
    this.onTafsir,
    this.onRepeat,
    this.onCopy,
    this.onShare,
  });

  final int number;
  final String arabic;
  final String translation;
  final String? transliteration;
  final bool active;
  final bool playing;
  final bool bookmarked;
  final String? playbackLabel;
  final String? repeatLabel;
  final double arabicFontSize;
  final VoidCallback? onPlay;
  final VoidCallback? onBookmark;
  final VoidCallback? onTafsir;
  final VoidCallback? onRepeat;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(palette),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.arabic(
                size: arabicFontSize,
                lineHeight: arabicFontSize * 2.15,
                weight: FontWeight.w400,
                color: palette.textPrimary,
              ),
            ),
          ),
        ),
        if (transliteration != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              transliteration!,
              style: AppTextStyles.label.copyWith(
                color: palette.accentLight,
              ),
            ),
          ),
        Text(
          translation,
          style: AppTextStyles.body.copyWith(
            color: active ? palette.textPrimary : palette.textMuted,
          ),
        ),
        if (active) _footer(palette),
      ],
    );

    return Semantics(
      container: true,
      selected: active,
      label: 'Ayat $number',
      child: active
          ? AppSurface(
              color: palette.accentSoft,
              borderColor: palette.borderAccent,
              radius: 16,
              padding: const EdgeInsets.all(16),
              child: body,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: palette.border)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                child: body,
              ),
            ),
    );
  }

  Widget _header(AppThemePalette palette) {
    return Row(
      children: [
        AppSurface(
          color: active ? palette.accent : palette.surface,
          borderColor: active ? null : palette.border,
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active && playing) ...[
                EqualizerBars(playing: true, color: palette.onAccent, height: 10),
                const SizedBox(width: 6),
              ],
              Text(
                active && playbackLabel != null
                    ? '$number · ${playbackLabel!.toUpperCase()}'
                    : '$number',
                style: AppTextStyles.micro.copyWith(
                  color: active ? palette.onAccent : palette.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconCircleButton(
          icon: playing ? AppIcons.pause : AppIcons.play,
          semanticLabel: playing ? 'Jeda ayat $number' : 'Putar ayat $number',
          style: IconCircleStyle.ghost,
          size: 32,
          iconSize: 15,
          iconColor: active ? palette.accentLight : palette.textMuted,
          onTap: onPlay,
        ),
        if (!active && onTafsir != null)
          IconCircleButton(
            icon: AppIcons.tafsir,
            semanticLabel: 'Tafsir ayat $number',
            size: 32,
            iconSize: 15,
            iconColor: palette.textMuted,
            onTap: onTafsir,
          ),
        IconCircleButton(
          icon: bookmarked ? AppIcons.bookmarkFilled : AppIcons.bookmark,
          semanticLabel: bookmarked
              ? 'Hapus penanda ayat $number'
              : 'Tandai ayat $number',
          size: 32,
          iconSize: 15,
          iconColor: bookmarked ? palette.accentLight : palette.textMuted,
          onTap: onBookmark,
        ),
        if (!active && onShare != null)
          IconCircleButton(
            icon: AppIcons.share,
            semanticLabel: 'Bagikan ayat $number',
            size: 32,
            iconSize: 15,
            iconColor: palette.textMuted,
            onTap: onShare,
          ),
      ],
    );
  }

  Widget _footer(AppThemePalette palette) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              PillButton(
                label: 'Tafsir',
                leadingIcon: AppIcons.tafsir,
                style: PillButtonStyle.action,
                onTap: onTafsir,
              ),
              if (repeatLabel != null) ...[
                const SizedBox(width: 6),
                PillButton(
                  label: repeatLabel,
                  leadingIcon: AppIcons.repeat,
                  style: PillButtonStyle.action,
                  onTap: onRepeat,
                ),
              ],
              const Spacer(),
              IconCircleButton(
                icon: AppIcons.copy,
                semanticLabel: 'Salin ayat $number',
                size: 32,
                iconSize: 14,
                iconColor: palette.textMuted,
                onTap: onCopy,
              ),
              IconCircleButton(
                icon: AppIcons.share,
                semanticLabel: 'Bagikan ayat $number',
                size: 32,
                iconSize: 14,
                iconColor: palette.textMuted,
                onTap: onShare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
