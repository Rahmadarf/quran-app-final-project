import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/media_card.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/quote_banner.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/shelf.dart';
import '../../player/application/player_providers.dart';
import '../../player/domain/media_item.dart';

/// Beranda dual-mode sesuai Figma `01 — Beranda (Home) · Audiophile Obsidian / Light`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _aisyah = AssetImage('assets/images/avatars/aisyah.png');

  static const _favoriteQaris = [
    (
      id: '05',
      name: 'Al-Afasi',
      image: AssetImage('assets/images/qari/misyari-rasyid-al-afasi.webp'),
    ),
    (
      id: '03',
      name: 'As-Sudais',
      image: AssetImage('assets/images/qari/abdurrahman-as-sudais.webp'),
    ),
    (
      id: '01',
      name: 'Al-Juhany',
      image: AssetImage('assets/images/qari/abdullah-al-juhany.webp'),
    ),
    (
      id: '04',
      name: 'Al-Dossari',
      image: AssetImage('assets/images/qari/ibrahim-al-dossari.webp'),
    ),
    (
      id: '02',
      name: 'Al-Qasim',
      image: AssetImage('assets/images/qari/abdul-muhsin-al-qasim.webp'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final palette = AppThemeScope.paletteOf(context);
    void openReader() => Navigator.of(context).pushNamed(AppRoutes.reader);
    void openCollection() =>
        Navigator.of(context).pushNamed(AppRoutes.collection);

    return ColoredBox(
      color: palette.background,
      child: Column(
        children: [
          AppTopBar(
            showBottomBorder: false,
            leading: const AvatarRing(
              image: _aisyah,
              onlineDot: true,
              semanticLabel: 'Foto profil Aisyah',
            ),
            center: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Assalamu'alaikum, Aisyah",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading
                      .copyWith(color: palette.textPrimary),
                ),
                Text(
                  'Lanjutkan tilawah hari ini',
                  style:
                      AppTextStyles.caption.copyWith(color: palette.textMuted),
                ),
              ],
            ),
            trailing: IconCircleButton(
              icon: AppIcons.search,
              semanticLabel: 'Cari tilawah',
              style: IconCircleStyle.outlined,
              iconColor: palette.textPrimary,
              iconSize: 16,
              onTap: openCollection,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 6, bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kartu Lanjutkan Mendengarkan sesuai Figma `Obsidian / ContinueCard`
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ContinueListeningCard(
                      title: player.state.current?.title ??
                          'Surah Ar-Rahman · Ayat 13',
                      subtitle:
                          '${player.selectedQariName} · sisa 08:42',
                      artwork: AssetImage(
                        player.state.current?.artwork ??
                            'assets/images/covers/ar-rahman.png',
                      ),
                      playing: player.playing,
                      onTap: openReader,
                      onPlay: player.togglePlay,
                    ),
                  ),
                  const Gap(22),
                  SectionHeader(
                    title: 'Qari Favorit',
                    trailingLabel: 'Lihat semua',
                    onTrailingTap: openCollection,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const Gap(12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < _favoriteQaris.length; i++) ...[
                          if (i > 0) const Gap(14),
                          QariAvatarItem(
                            image: _favoriteQaris[i].image,
                            name: _favoriteQaris[i].name,
                            selected:
                                player.selectedQariId == _favoriteQaris[i].id,
                            onTap: () => unawaited(
                              player.selectQari(_favoriteQaris[i].id),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(24),
                  Shelf(
                    title: 'Rekomendasi Tilawah',
                    onSeeAll: openCollection,
                    children: [
                      MediaCard(
                        image: const AssetImage(
                          'assets/images/covers/ar-rahman.png',
                        ),
                        arabicTitle: 'الرحمن',
                        title: 'Surat Ar-Rahman',
                        subtitle: 'Misyari Rasyid Al-Afasi',
                        onTap: openReader,
                      ),
                      MediaCard(
                        image: const AssetImage(
                          'assets/images/covers/al-kahfi.png',
                        ),
                        arabicTitle: 'الكهف',
                        pillLabel: 'Jumat',
                        title: 'Surat Al-Kahfi',
                        subtitle: 'Abdurrahman As-Sudais',
                        onTap: () => PlayerScope.read(context)
                            .playSurah(18, qariId: '03'),
                      ),
                      MediaCard(
                        image: const AssetImage(
                          'assets/images/covers/yasin.png',
                        ),
                        arabicTitle: 'يس',
                        title: 'Surat Yasin',
                        subtitle: 'Abdullah Al-Juhany',
                        onTap: () => PlayerScope.read(context)
                            .playSurah(36, qariId: '01'),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Shelf(
                    title: 'Koleksi Pilihan',
                    onSeeAll: openCollection,
                    children: [
                      MediaCard(
                        image: const AssetImage(
                          'assets/images/backgrounds/starfield.png',
                        ),
                        badgeIcon: AppIcons.sparkle,
                        overlayLabel: 'KOLEKSI 2024',
                        title: 'Surat Populer 2024',
                        subtitle: '6 Surat · 3j 45mnt',
                        onTap: openCollection,
                      ),
                      MediaCard(
                        image: const AssetImage(
                          'assets/images/covers/dzikir-petang.png',
                        ),
                        badgeIcon: AppIcons.adhkar,
                        overlayLabel: 'VOCAL-ONLY',
                        title: 'Dzikir Penenang Petang',
                        subtitle: 'Vocal-only, tanpa musik',
                        onTap: () => PlayerScope.read(context).playItem(
                          MediaItem(
                            id: 'adhkar:a-petang',
                            kind: MediaKind.adhkar,
                            source: MediaSource.mock,
                            title: 'Dzikir Penenang Petang',
                            subtitle: 'Vocal-only · Contoh Audio',
                            duration: const Duration(minutes: 3, seconds: 15),
                            audioUri: Uri.parse(
                              'asset://assets/audio_samples/sample_01.mp3',
                            ),
                            artwork: 'assets/images/covers/dzikir-petang.png',
                          ),
                          queueSource: 'Koleksi Pilihan',
                        ),
                      ),
                      MediaCard(
                        image: const AssetImage(
                          'assets/images/covers/mix-harian.png',
                        ),
                        badgeIcon: AppIcons.tafsir,
                        overlayLabel: 'MIX HARIAN',
                        title: 'Daily Murattal Mix 1',
                        subtitle: 'Al-Afasi, As-Sudais, Al-Juhany',
                        onTap: openCollection,
                      ),
                    ],
                  ),
                  const Gap(24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: QuoteBanner(
                      quote:
                          'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
                      reference: "QS. Ar-Ra'd : 28",
                    ),
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

class _ContinueListeningCard extends StatelessWidget {
  const _ContinueListeningCard({
    required this.title,
    required this.subtitle,
    required this.artwork,
    required this.playing,
    required this.onTap,
    required this.onPlay,
  });

  final String title;
  final String subtitle;
  final ImageProvider artwork;
  final bool playing;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: 'Lanjutkan mendengarkan $title',
      pressedScale: 0.99,
      child: AppSurface(
        color: palette.surface,
        borderColor: palette.border,
        radius: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              child: Row(
                children: [
                  AppSurface(
                    width: 48,
                    height: 48,
                    radius: 8,
                    color: palette.surfaceElevated,
                    child: Image(
                      image: ResizeImage.resizeIfNeeded(144, null, artwork),
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LANJUTKAN MENDENGARKAN',
                          style: AppTextStyles.micro
                              .copyWith(color: palette.accentLight),
                        ),
                        const Gap(2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle
                              .copyWith(color: palette.textPrimary),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption
                              .copyWith(color: palette.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  IconCircleButton(
                    icon: playing ? AppIcons.pause : AppIcons.play,
                    semanticLabel: playing ? 'Jeda' : 'Lanjutkan putar',
                    style: IconCircleStyle.primary,
                    size: 38,
                    iconSize: 15,
                    onTap: onPlay,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 3,
              child: ColoredBox(
                color: palette.surfaceElevated,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.38,
                    child: ColoredBox(
                      color: palette.accent,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
