import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/equalizer_bars.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../../player/application/player_providers.dart';
import '../../player/domain/media_item.dart';
import '../../player/presentation/mini_player.dart';

/// Layar 07 — Detail Koleksi (Surat Populer 2024) dual-mode sesuai Figma.
class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({super.key});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  static const _tracks = [
    (
      index: '01',
      surahNo: 55,
      title: 'Surat Ar-Rahman',
      qariId: '05',
      qari: 'Misyari Rasyid Al-Afasi',
      duration: '13:00',
    ),
    (
      index: '02',
      surahNo: 18,
      title: 'Surat Al-Kahfi',
      qariId: '03',
      qari: 'Abdurrahman As-Sudais',
      duration: '29:14',
    ),
    (
      index: '03',
      surahNo: 36,
      title: 'Surat Yasin',
      qariId: '01',
      qari: 'Abdullah Al-Juhany',
      duration: '14:42',
    ),
    (
      index: '04',
      surahNo: 67,
      title: 'Surat Al-Mulk',
      qariId: '02',
      qari: 'Abdul Muhsin Al-Qasim',
      duration: '08:25',
    ),
    (
      index: '05',
      surahNo: 56,
      title: "Surat Al-Waqi'ah",
      qariId: '04',
      qari: 'Ibrahim Al-Dossari',
      duration: '11:18',
    ),
    (
      index: '06',
      surahNo: 19,
      title: 'Surat Maryam',
      qariId: '06',
      qari: 'Yasser Al-Dosari',
      duration: '18:06',
    ),
  ];

  final Set<int> _liked = {55, 36};

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final palette = AppThemeScope.paletteOf(context);
    final activeSurahNo = player.state.current?.surahNumber ?? 55;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: palette.background,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Starfield Header (tetap kontras tinggi pada Dark & Light)
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 312 + topInset),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/backgrounds/starfield.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0x660A0B0D),
                              const Color(0xBF0A0B0D),
                              palette.isDark
                                  ? palette.background
                                  : const Color(0xF00A0B0D),
                            ],
                            stops: const [0.0, 0.62, 1.0],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            topInset + 12,
                            20,
                            20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _HeroCircleButton(
                                    icon: AppIcons.arrowBack,
                                    semanticLabel: 'Kembali',
                                    onTap: () =>
                                        Navigator.of(context).maybePop(),
                                  ),
                                  Row(
                                    children: [
                                      _HeroCircleButton(
                                        icon: AppIcons.share,
                                        semanticLabel: 'Bagikan koleksi',
                                        onTap: () => unawaited(
                                          SharePlus.instance.share(
                                            ShareParams(
                                              text:
                                                  'Koleksi Surat Populer 2024 — Lantunan ayat suci Al-Qur\'an pilihan.',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(8),
                                      _HeroCircleButton(
                                        icon: AppIcons.moreVert,
                                        semanticLabel: 'Opsi koleksi',
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(42),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 6,
                                        height: 6,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      const Gap(7),
                                      Flexible(
                                        child: Text(
                                          'KOLEKSI TILAWAH PILIHAN',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.micro.copyWith(
                                            color: const Color(0xFF34D399),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Surat Populer 2024',
                                    style: AppTextStyles.custom(
                                      size: 30,
                                      lineHeight: 34,
                                      weight: FontWeight.w700,
                                      letterSpacing: -0.75,
                                      color: const Color(0xFFF8F9FA),
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    "Lantunan ayat suci Al-Qur'an pilihan dengan qari terkemuka dunia.",
                                    style: AppTextStyles.body.copyWith(
                                      color: const Color(0xFFCBD2D9),
                                    ),
                                  ),
                                  const Gap(14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const AppIcon(
                                                  AppIcons.heartFilled,
                                                  size: 13,
                                                  color: Color(0xFF34D399),
                                                ),
                                                const Gap(6),
                                                Flexible(
                                                  child: Text(
                                                    '1.450.210 pendengar',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles.label
                                                        .copyWith(
                                                      color: const Color(
                                                        0xFFF8F9FA,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Gap(3),
                                            Row(
                                              children: [
                                                const AppIcon(
                                                  AppIcons.timer,
                                                  size: 13,
                                                  color: Color(0xFFCBD2D9),
                                                ),
                                                const Gap(6),
                                                Flexible(
                                                  child: Text(
                                                    '6 Surat · 3j 45mnt',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles.caption
                                                        .copyWith(
                                                      color: const Color(
                                                        0xFFCBD2D9,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Gap(10),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _HeroCircleButton(
                                            icon: AppIcons.shuffle,
                                            semanticLabel: 'Putar acak',
                                            size: 42,
                                            onTap: player.toggleShuffle,
                                          ),
                                          const Gap(10),
                                          IconCircleButton(
                                            icon: player.playing
                                                ? AppIcons.pause
                                                : AppIcons.play,
                                            semanticLabel: 'Putar koleksi',
                                            style: IconCircleStyle.primary,
                                            size: 50,
                                            iconSize: 20,
                                            onTap: () => player.playSurah(
                                              _tracks.first.surahNo,
                                              qariId: _tracks.first.qariId,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Daftar Tilawah (Zero-card hairline list)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daftar Tilawah',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.heading
                                        .copyWith(color: palette.textPrimary),
                                  ),
                                  Text(
                                    'Lantunan ayat suci penuh ketenangan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption
                                        .copyWith(color: palette.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(12),
                            AppSurface(
                              color: palette.surface,
                              borderColor: palette.border,
                              radius: 999,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                '6 SURAT',
                                style: AppTextStyles.micro
                                    .copyWith(color: palette.textMuted),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        for (final track in _tracks)
                          _CollectionTrackRow(
                            index: track.index,
                            title: track.title,
                            subtitle: '${track.qari} · ${track.duration}',
                            active: activeSurahNo == track.surahNo,
                            playing:
                                player.playing && activeSurahNo == track.surahNo,
                            liked: _liked.contains(track.surahNo),
                            onTap: () => unawaited(
                              player.playSurah(
                                track.surahNo,
                                qariId: track.qariId,
                                qariName: track.qari,
                              ),
                            ),
                            onLikeTap: () => setState(() {
                              if (!_liked.add(track.surahNo)) {
                                _liked.remove(track.surahNo);
                              }
                            }),
                            onMoreTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.readerFor(track.surahNo),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Docked floating Mini Player
          Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 12 + bottomInset),
            child: PlaybackPositionBuilder(
              positionListenable: player.positionListenable,
              builder: (context, pos) {
                final cur = player.state.current;
                final isAyah = cur?.kind == MediaKind.ayah;
                final surahLatin = cur?.meta['surahLatinName'] as String?;
                final miniTitle = isAyah && surahLatin != null
                    ? 'Surat $surahLatin'
                    : (cur?.title ?? 'Surah Ar-Rahman');
                final miniSubtitle = isAyah && cur?.ayahNumber != null
                    ? 'Ayat ${cur!.ayahNumber} · ${cur.subtitle}'
                    : (cur?.subtitle ?? player.selectedQariName);
                final miniProgress = isAyah &&
                        cur?.ayahNumber != null &&
                        (cur?.ayahCount ?? 0) > 0
                    ? (cur!.ayahNumber! / cur.ayahCount!).clamp(0.0, 1.0)
                    : pos.progress;
                return MiniPlayer(
                  leading: MiniPlayerLeading.image(
                    AssetImage(
                      cur?.artwork ?? 'assets/images/covers/ar-rahman.png',
                    ),
                  ),
                  title: miniTitle,
                  subtitle: miniSubtitle,
                  progress: miniProgress,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.player),
                  actions: [
                    IconCircleButton(
                      icon: player.favorite
                          ? AppIcons.heartFilled
                          : AppIcons.heart,
                      semanticLabel: 'Favorit',
                      size: 34,
                      iconSize: 16,
                      iconColor: player.favorite
                          ? palette.accent
                          : palette.textMuted,
                      onTap: player.toggleFavorite,
                    ),
                    IconCircleButton(
                      icon: player.playing ? AppIcons.pause : AppIcons.play,
                      semanticLabel: player.playing ? 'Jeda' : 'Putar',
                      style: IconCircleStyle.primary,
                      size: 34,
                      iconSize: 13,
                      onTap: player.togglePlay,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.size = 38,
  });

  final AppIcons icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: AppSurface(
        shape: BoxShape.circle,
        color: const Color(0xCC131519),
        borderColor: const Color(0x33FFFFFF),
        width: size,
        height: size,
        child: Center(
          child: AppIcon(icon, size: 17, color: const Color(0xFFF8F9FA)),
        ),
      ),
    );
  }
}

class _CollectionTrackRow extends StatelessWidget {
  const _CollectionTrackRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.playing,
    required this.liked,
    required this.onTap,
    required this.onLikeTap,
    required this.onMoreTap,
  });

  final String index;
  final String title;
  final String subtitle;
  final bool active;
  final bool playing;
  final bool liked;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    final row = Row(
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: active
              ? AppSurface(
                  color: palette.accent,
                  radius: 8,
                  child: Center(
                    child: EqualizerBars(
                      playing: playing,
                      color: palette.onAccent,
                      height: 14,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    index,
                    style: AppTextStyles.label
                        .copyWith(color: palette.textSubtle),
                  ),
                ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(
                  color: active ? palette.accentLight : palette.textPrimary,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: palette.textMuted),
              ),
            ],
          ),
        ),
        Pressable(
          onTap: onLikeTap,
          semanticLabel: liked ? 'Hapus favorit $title' : 'Favoritkan $title',
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AppIcon(
              liked ? AppIcons.heartFilled : AppIcons.heart,
              size: 16,
              color: liked ? palette.accent : palette.textMuted,
            ),
          ),
        ),
        Pressable(
          onTap: onMoreTap,
          semanticLabel: 'Buka $title di Reader',
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: AppIcon(
              AppIcons.moreVert,
              size: 16,
              color: palette.textMuted,
            ),
          ),
        ),
      ],
    );

    return Pressable(
      onTap: onTap,
      semanticLabel: '$title, $subtitle',
      pressedScale: 0.99,
      child: active
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AppSurface(
                color: palette.accentSoft,
                borderColor: palette.borderAccent,
                radius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: row,
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: palette.border)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: row,
              ),
            ),
    );
  }
}
