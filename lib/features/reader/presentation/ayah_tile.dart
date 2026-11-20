import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/equalizer_bars.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pill_button.dart';

/// Kartu satu ayat di Reader.
///
/// Keadaan biasa: nomor, aksi putar + penanda, teks Arab, transliterasi,
/// terjemahan. Keadaan [active] (sedang diputar/disorot SyncEngine) menambah
/// cahaya di tepi, penanda "Memutar", dan baris aksi (tafsir, ulang, salin,
/// bagikan). Teks Arab, transliterasi, dan terjemahan ditampilkan apa adanya.
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
    this.arabicFontSize = 22,
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

  /// Ayat yang sedang disorot.
  final bool active;

  /// Audio ayat ini sedang berjalan (ikon jeda dan batang equalizer).
  final bool playing;
  final bool bookmarked;

  /// Mis. "Memutar 00:03". Hanya tampil saat [active].
  final String? playbackLabel;

  /// Mis. "Ulang 3x". Bila null, tombol ulang tidak tampil.
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
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.arabic(
                size: arabicFontSize,
                lineHeight: arabicFontSize * 2,
                weight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.accentLight : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (transliteration != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              transliteration!,
              style: AppTextStyles.custom(
                size: 12,
                lineHeight: 16,
                weight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.accentLight : AppColors.skyLabel,
                letterSpacing: 0.3,
              ),
            ),
          ),
        Text(
          translation,
          style: AppTextStyles.custom(
            size: 14,
            lineHeight: 20,
            weight: active ? FontWeight.w500 : FontWeight.w400,
            color: active ? AppColors.textPrimary : AppColors.textSubtle,
          ),
        ),
        if (active) _footer(),
      ],
    );

    return Semantics(
      container: true,
      selected: active,
      label: 'Ayat $number',
      child: active
          ? AppSurface(
              color: AppColors.surfaceActive,
              borderColor: AppColors.lightAt(0.3),
              radius: 12,
              shadows: [
                const BoxShadow(color: AppColors.accent, spreadRadius: 1),
                BoxShadow(
                  color: AppColors.accentAt(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentAt(0.2),
                            AppColors.accentLight,
                            AppColors.accentAt(0.2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightAt(0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(17), child: body),
                ],
              ),
            )
          : AppSurface(
              color: AppColors.surfaceVerse,
              borderColor: AppColors.borderAt(0.3),
              radius: 12,
              padding: const EdgeInsets.all(16),
              child: body,
            ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        AppSurface(
          shape: BoxShape.circle,
          width: 28,
          height: 28,
          color: active ? AppColors.accentLight : AppColors.surface,
          child: Center(
            child: Text(
              '$number',
              style: AppTextStyles.micro.copyWith(
                fontWeight: FontWeight.w700,
                color: active ? const Color(0xFF001F26) : AppColors.accentLight,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        if (active && playbackLabel != null) ...[
          const SizedBox(width: 8),
          AppSurface(
            color: AppColors.surface,
            borderColor: AppColors.accentAt(0.4),
            radius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EqualizerBars(playing: playing),
                const SizedBox(width: 4),
                Text(
                  playbackLabel!,
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.accentLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        IconCircleButton(
          icon: playing ? AppIcons.pause : AppIcons.playOutline,
          semanticLabel: playing ? 'Jeda ayat $number' : 'Putar ayat $number',
          style: active ? IconCircleStyle.primary : IconCircleStyle.ghost,
          size: 32,
          iconSize: active ? 13 : 16,
          iconColor: active ? AppColors.onLight : AppColors.textMuted,
          onTap: onPlay,
        ),
        const SizedBox(width: 4),
        IconCircleButton(
          icon: bookmarked ? AppIcons.bookmarkFilled : AppIcons.bookmark,
          semanticLabel: bookmarked
              ? 'Hapus penanda ayat $number'
              : 'Tandai ayat $number',
          size: 32,
          iconSize: 14,
          iconColor: bookmarked ? AppColors.accentLight : AppColors.textMuted,
          onTap: onBookmark,
        ),
      ],
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderAt(0.5))),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 9),
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
                iconSize: 13,
                iconColor: AppColors.textFaint,
                onTap: onCopy,
              ),
              IconCircleButton(
                icon: AppIcons.share,
                semanticLabel: 'Bagikan ayat $number',
                size: 32,
                iconSize: 13,
                iconColor: AppColors.textFaint,
                onTap: onShare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
