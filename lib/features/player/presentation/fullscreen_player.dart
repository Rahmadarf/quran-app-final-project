import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pill_button.dart';
import '../application/player_controller.dart';
import 'ayah_lyrics_view.dart';
import 'player_controls.dart';
import 'qari_footer_card.dart';
import 'seek_bar.dart';

/// Fullscreen Player: ayat bergaya lirik, bilah geser, dan kontrol utama.
///
/// Teks ayat di sini adalah contoh dari Figma (Ar-Rahman 13); pada
/// implementasi nyata diisi dari data surat yang sedang diputar.
class FullscreenPlayerScreen extends StatelessWidget {
  const FullscreenPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage('assets/images/backgrounds/starfield.png'),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundAt(0.9),
                  AppColors.surfaceAt(0.7),
                  const Color(0xF2071329),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background,
                  AppColors.backgroundAt(0.7),
                  AppColors.backgroundAt(0),
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
          Column(
            children: [
              AppTopBar(
                centered: true,
                showBottomBorder: false,
                background: AppColors.backgroundAt(0.85),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                leading: IconCircleButton(
                  icon: AppIcons.chevronDown,
                  semanticLabel: 'Perkecil pemutar',
                  size: 44,
                  iconSize: 14,
                  iconColor: AppColors.textMuted,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MEMUTAR SURAT',
                      style: AppTextStyles.micro.copyWith(
                        color: AppColors.accentLight,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Ar-Rahman',
                      style: AppTextStyles.custom(
                        size: 18,
                        lineHeight: 24,
                        weight: FontWeight.w600,
                        color: AppColors.textPlayerTitle,
                        letterSpacing: -0.45,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconCircleButton(
                      icon: AppIcons.share,
                      semanticLabel: 'Bagikan',
                      iconSize: 17,
                      iconColor: AppColors.textMuted,
                      onTap: () {},
                    ),
                    const SizedBox(width: 4),
                    PillButton(
                      label: 'Mushaf',
                      leadingIcon: AppIcons.mushaf,
                      iconSize: 14,
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      style: PillButtonStyle.highlight,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.reader),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: AyahLyricsView(
                      previousArabic: 'الرَّحْمَٰنُ (١) عَلَّمَ الْقُرْآنَ (٢)',
                      activeArabic: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
                      translation:
                          'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
                      nextArabic: 'خَلَقَ الْإِنسَانَ (٣) عَلَّمَهُ الْبَيَانَ (٤)',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  32 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Surat Ar-Rahman',
                                style: AppTextStyles.custom(
                                  size: 22,
                                  lineHeight: 33,
                                  weight: FontWeight.w700,
                                  color: AppColors.textPlayerTitle,
                                  letterSpacing: -0.55,
                                ),
                              ),
                              Text(
                                'Misyari Rasyid Al-Afasi ·',
                                style: AppTextStyles.custom(
                                  size: 14,
                                  lineHeight: 20,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconCircleButton(
                          icon: player.favorite
                              ? AppIcons.heartFilled
                              : AppIcons.heart,
                          semanticLabel: player.favorite
                              ? 'Hapus dari favorit'
                              : 'Simpan ke favorit',
                          style: IconCircleStyle.glass,
                          size: 44,
                          iconSize: 20,
                          iconColor: AppColors.accentLight,
                          onTap: player.toggleFavorite,
                        ),
                        const SizedBox(width: 4),
                        IconCircleButton(
                          icon: AppIcons.check,
                          semanticLabel: 'Tersedia offline',
                          style: IconCircleStyle.glass,
                          size: 44,
                          iconSize: 15,
                          iconColor: AppColors.accentLight,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SeekBar(
                      value: player.progress,
                      buffered: (player.progress + 0.4).clamp(0.0, 1.0),
                      semanticValue:
                          '${formatClock(player.elapsedSeconds)} dari ${formatClock(player.totalSeconds)}',
                      onChanged: player.seek,
                    ),
                    const SizedBox(height: 4),
                    PlayerTimeline(
                      elapsed: formatClock(player.elapsedSeconds),
                      remaining: '-${formatClock(player.remainingSeconds)}',
                      centerLabel: 'Ayat 13 dari 78',
                    ),
                    const SizedBox(height: 16),
                    PlayerControls(
                      playing: player.playing,
                      shuffleOn: player.shuffle,
                      repeatOne: player.repeatOne,
                      onShuffle: player.toggleShuffle,
                      onPlayPause: player.togglePlay,
                      onRepeat: player.toggleRepeatOne,
                      onPrevious: () => player.seek(0),
                      onNext: () => player.seek(1),
                    ),
                    const SizedBox(height: 24),
                    QariFooterCard(
                      image: const AssetImage('assets/images/qari/misyari-rasyid-al-afasi.webp'),
                      name: 'Misyari Rasyid Al-Afasi',
                      subtitle: 'Koleksi Murattal 30 Juz Bersuara Emas',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
