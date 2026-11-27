import 'dart:async';

import 'package:flutter/widgets.dart' hide RepeatMode;
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/duration_format.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pill_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/surah.dart';
import '../../reader/application/sync_engine.dart';
import '../application/player_controller.dart';
import '../domain/media_item.dart';
import '../domain/player_state.dart';
import 'ayah_lyrics_view.dart';
import 'ayah_picker_sheet.dart';
import 'playback_selector_card.dart';
import 'player_controls.dart';
import 'qari_picker_sheet.dart';
import 'queue_sheet.dart';
import 'seek_bar.dart';
import 'sleep_timer_sheet.dart';
import 'speed_sheet.dart';
import 'surah_picker_sheet.dart';

/// Fullscreen Player dual-mode sesuai Figma `06 — Fullscreen Player (Synced)`.
class FullscreenPlayerScreen extends StatefulWidget {
  const FullscreenPlayerScreen({super.key});

  @override
  State<FullscreenPlayerScreen> createState() => _FullscreenPlayerScreenState();
}

class _FullscreenPlayerScreenState extends State<FullscreenPlayerScreen> {
  static const _qaris = [
    QariOption(
      id: '05',
      name: 'Misyari Rasyid Al-Afasi',
      origin: 'Kuwait · Murattal',
      photo: AssetImage('assets/images/qari/misyari-rasyid-al-afasi.webp'),
    ),
    QariOption(
      id: '03',
      name: 'Abdurrahman As-Sudais',
      origin: 'Arab Saudi · Murattal',
      photo: AssetImage('assets/images/qari/abdurrahman-as-sudais.webp'),
    ),
    QariOption(
      id: '01',
      name: 'Abdullah Al-Juhany',
      origin: 'Arab Saudi · Murattal',
      photo: AssetImage('assets/images/qari/abdullah-al-juhany.webp'),
    ),
    QariOption(
      id: '02',
      name: 'Abdul Muhsin Al-Qasim',
      origin: 'Arab Saudi · Murattal',
      photo: AssetImage('assets/images/qari/abdul-muhsin-al-qasim.webp'),
    ),
    QariOption(
      id: '04',
      name: 'Ibrahim Al-Dossari',
      origin: 'Arab Saudi · Murattal',
      photo: AssetImage('assets/images/qari/ibrahim-al-dossari.webp'),
    ),
    QariOption(
      id: '06',
      name: 'Yasser Al-Dosari',
      origin: 'Arab Saudi · Murattal',
      photo: AssetImage('assets/images/qari/yasser-al-dossari.webp'),
    ),
  ];

  static const _fallbackSurahs = [
    SurahOption(number: 1, name: 'Al-Fatihah', ayahCount: 7),
    SurahOption(number: 2, name: 'Al-Baqarah', ayahCount: 286),
    SurahOption(number: 18, name: 'Al-Kahf', ayahCount: 110),
    SurahOption(number: 36, name: 'Ya Sin', ayahCount: 83),
    SurahOption(number: 55, name: 'Ar-Rahman', ayahCount: 78),
    SurahOption(number: 67, name: 'Al-Mulk', ayahCount: 30),
    SurahOption(number: 112, name: 'Al-Ikhlas', ayahCount: 4),
  ];

  QariOption _qari = _qaris.first;
  SurahOption _surah = _fallbackSurahs[4];
  int _ayah = 13;

  final SyncEngine _syncEngine = const SyncEngine();
  Surah? _loadedSurah;
  int? _fetchingSurahNo;

  void _ensureSurahLoaded(BuildContext context, int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return;
    if (_loadedSurah?.number == surahNumber ||
        _fetchingSurahNo == surahNumber) {
      return;
    }
    _fetchingSurahNo = surahNumber;
    final repo = ReaderScope.read(context).repository;
    unawaited(
      repo.getSurahDetail(surahNumber).then((surah) {
        if (!mounted) return;
        setState(() {
          _loadedSurah = surah;
          _fetchingSurahNo = null;
        });
      }).catchError((_) {
        if (mounted && _fetchingSurahNo == surahNumber) {
          _fetchingSurahNo = null;
        }
      }),
    );
  }

  QariOption _activeQari(PlayerController player) {
    return _qaris.firstWhere(
      (q) => q.id == player.selectedQariId,
      orElse: () => _qari,
    );
  }

  Future<void> _pickQari(PlayerController player) async {
    final currentQari = _activeQari(player);
    final result =
        await showQariPicker(context, options: _qaris, selected: currentQari);
    if (result != null && mounted) {
      setState(() => _qari = result);
      final current = player.state.current;
      final targetSurah = current?.surahNumber ?? _surah.number;
      final keepAyah = current?.kind == MediaKind.ayah
          ? (current?.ayahNumber ?? _ayah)
          : null;
      unawaited(
        player.playSurah(
          targetSurah,
          qariId: result.id,
          qariName: result.name,
          startAyah: keepAyah,
          preferPerAyah: current?.kind != MediaKind.surah,
        ),
      );
    }
  }

  Future<void> _pickSurah(PlayerController player) async {
    var options = _fallbackSurahs;
    if (player.cachedSurahs.isNotEmpty) {
      options = player.cachedSurahs
          .map(
            (s) => SurahOption(
              number: s.number,
              name: s.latinName,
              ayahCount: s.ayahCount,
            ),
          )
          .toList(growable: false);
    } else {
      unawaited(player.loadSurahs().then<void>((_) {}, onError: (_) {}));
    }

    final currentSurahNo = player.state.current?.surahNumber ?? _surah.number;
    final selectedSurah = options.firstWhere(
      (s) => s.number == currentSurahNo,
      orElse: () => _surah,
    );
    final result = await showSurahPicker(
      context,
      options: options,
      selected: selectedSurah,
    );
    if (result != null && result.number != currentSurahNo && mounted) {
      setState(() {
        _surah = result;
        _ayah = 1;
      });
      final activeQari = _activeQari(player);
      unawaited(
        player.playSurah(
          result.number,
          qariId: activeQari.id,
          qariName: activeQari.name,
          startAyah: 1,
        ),
      );
    }
  }

  int _resolvedAyahNumber(
    MediaItem? current,
    PlaybackPosition pos,
    int activeAyahCount,
  ) {
    // Mode A (per ayat): langsung ambil nomor ayat dari item aktif meskipun
    // detail teks surat masih memuat.
    if (current != null &&
        current.kind == MediaKind.ayah &&
        current.ayahNumber != null) {
      return current.ayahNumber!.clamp(1, activeAyahCount);
    }
    final surah = _loadedSurah;
    if (surah != null &&
        current != null &&
        surah.number == current.surahNumber &&
        surah.ayat.isNotEmpty) {
      final sync = _syncEngine.resolve(
        surah: surah,
        current: current,
        pos: pos,
      );
      if (sync.activeAyah != null) {
        return sync.activeAyah!.clamp(1, activeAyahCount);
      }
    }
    return _ayah.clamp(1, activeAyahCount);
  }

  Future<void> _pickAyah(
    PlayerController player,
    int surahNumber,
    String surahName,
    int ayahCount,
    int currentAyah,
  ) async {
    final result = await showAyahPicker(
      context,
      surahName: surahName,
      ayahCount: ayahCount,
      current: currentAyah.clamp(1, ayahCount),
    );
    if (result != null && mounted) {
      setState(() => _ayah = result);
      final current = player.state.current;
      // Mode A: lompat instan & eksak ke indeks ayat dalam native playlist.
      if (current != null &&
          current.kind == MediaKind.ayah &&
          current.surahNumber == surahNumber) {
        final jumped = await player.jumpToAyah(result);
        if (jumped) return;
      }
      if (current == null) {
        final activeQari = _activeQari(player);
        unawaited(
          player.playSurah(
            surahNumber,
            qariId: activeQari.id,
            qariName: activeQari.name,
            startAyah: result,
          ),
        );
        return;
      }
      // Mode B: fallback perkiraan waktu pada audio surat penuh.
      final surah = _loadedSurah;
      final total = player.position.duration ?? current.duration;
      if (surah != null && total != null && total.inMilliseconds > 0) {
        final targetPos = _syncEngine.startTimeForAyah(surah, result, total);
        unawaited(player.seekTo(targetPos));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final palette = AppThemeScope.paletteOf(context);
    final state = player.state;
    final current = state.current;
    final activeQari = _activeQari(player);

    final activeSurahNumber = current?.surahNumber ?? _surah.number;
    final activeSurahName =
        (current?.meta['surahLatinName'] as String?) ?? _surah.name;
    final activeAyahCount = current?.ayahCount ?? _surah.ayahCount;
    final activeQariName = current?.subtitle ?? activeQari.name;
    final isSurah = current == null || current.kind.hasReader;
    final isPerAyah = current == null || current.kind == MediaKind.ayah;
    final displayTitle = isSurah
        ? 'Surat $activeSurahName'
        : (current.title);
    final artworkPath =
        current?.artwork ?? 'assets/images/covers/ar-rahman.png';

    if (isSurah) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureSurahLoaded(context, activeSurahNumber);
      });
    }

    return ColoredBox(
      color: palette.background,
      child: Column(
        children: [
          AppTopBar(
            centered: true,
            showBottomBorder: false,
            background: palette.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: IconCircleButton(
              icon: AppIcons.chevronDown,
              semanticLabel: 'Perkecil pemutar',
              style: IconCircleStyle.outlined,
              size: 38,
              iconSize: 14,
              iconColor: palette.textPrimary,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.queueSource?.toUpperCase() ?? 'MEMUTAR DARI AL-QUR\'AN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.micro.copyWith(color: palette.textMuted),
                ),
                if (isSurah)
                  Text(
                    isPerAyah
                        ? 'Mode Per Ayat · Akurat'
                        : 'Mode Penuh · Perkiraan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: isPerAyah ? palette.accentLight : palette.warning,
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
                  style: IconCircleStyle.outlined,
                  size: 38,
                  iconSize: 16,
                  iconColor: palette.textPrimary,
                  onTap: () => unawaited(
                    SharePlus.instance.share(
                      ShareParams(
                        text: 'Mendengarkan $displayTitle oleh $activeQariName',
                      ),
                    ),
                  ),
                ),
                if (isSurah) ...[
                  const Gap(6),
                  PillButton(
                    label: 'Baca',
                    leadingIcon: AppIcons.mushaf,
                    iconSize: 14,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    style: PillButtonStyle.highlight,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.readerFor(activeSurahNumber),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (state.phase == PlayerPhase.error && state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: AppSurface(
                color: palette.dangerSoft,
                borderColor: palette.danger,
                radius: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.error!.message,
                        style: AppTextStyles.caption
                            .copyWith(color: palette.danger),
                      ),
                    ),
                    const Gap(8),
                    SizedBox(
                      width: 88,
                      child: AppButton(
                        label: 'Coba lagi',
                        height: 32,
                        onTap: player.retry,
                      ),
                    ),
                    if (state.error!.canSkip) ...[
                      const Gap(6),
                      SizedBox(
                        width: 72,
                        child: AppButton(
                          label: 'Lewati',
                          height: 32,
                          onTap: player.next,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  // Cover Art sesuai Figma 06 — Fullscreen Player
                  AppSurface(
                    width: 210,
                    height: 210,
                    radius: 16,
                    color: palette.surface,
                    borderColor: palette.borderStrong,
                    shadows: [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                        spreadRadius: -6,
                      ),
                    ],
                    child: Image(
                      image: ResizeImage.resizeIfNeeded(
                        512,
                        null,
                        AssetImage(artworkPath),
                      ),
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const Gap(18),

                  // Live Synced Ayah Strip
                  PlaybackPositionBuilder(
                    positionListenable: player.positionListenable,
                    builder: (context, pos) {
                      final surah = _loadedSurah?.number == activeSurahNumber
                          ? _loadedSurah
                          : null;
                      if (surah != null && surah.ayat.isNotEmpty) {
                        final sync = current != null
                            ? _syncEngine.resolve(
                                surah: surah,
                                current: current,
                                pos: pos,
                              )
                            : const SyncResult();
                        final ayahNo = (sync.activeAyah ?? _ayah)
                            .clamp(1, surah.ayat.length);
                        final active = surah.ayat[ayahNo - 1];
                        return AyahLyricsView(
                          ayahLabel: 'Ayat $ayahNo dari ${surah.ayahCount}',
                          activeArabic: active.arabic,
                          translation: active.translation,
                        );
                      }
                      if (activeSurahNumber == 55) {
                        return const AyahLyricsView(
                          ayahLabel: 'Ayat 13 dari 78',
                          activeArabic: 'فَبِاَيِّ اٰلَاۤءِ رَبِّكُمَا تُكَذِّبٰنِ',
                          translation:
                              'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
                        );
                      }
                      return AyahLyricsView(
                        ayahLabel: 'Surat $activeSurahName',
                        activeArabic: (current?.meta['surahArabicName']
                                as String?) ??
                            activeSurahName,
                        translation: 'Memuat ayat Surat $activeSurahName…',
                      );
                    },
                  ),
                  const Gap(18),

                  // Judul & Qari + Favorit
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.display
                                  .copyWith(color: palette.textPrimary),
                            ),
                            Text(
                              '$activeQariName · ${current?.source.name == 'local' ? 'Lokal' : 'Stream'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body
                                  .copyWith(color: palette.textMuted),
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
                        size: 42,
                        iconSize: 20,
                        iconColor: player.favorite
                            ? palette.accent
                            : palette.textMuted,
                        onTap: player.toggleFavorite,
                      ),
                    ],
                  ),
                  const Gap(12),

                  // Seek bar & timeline
                  RepaintBoundary(
                    child: PlaybackPositionBuilder(
                      positionListenable: player.positionListenable,
                      builder: (context, pos) => Column(
                        children: [
                          SeekBar(
                            value: pos.progress,
                            buffered: pos.bufferedProgress,
                            semanticValue:
                                '${formatDurationSemantic(pos.position)} dari ${formatDurationSemantic(pos.duration)}',
                            onChanged:
                                pos.duration != null ? player.seek : null,
                          ),
                          const Gap(4),
                          PlayerTimeline(
                            elapsed: formatDuration(pos.position),
                            remaining:
                                formatRemaining(pos.position, pos.duration),
                            centerLabel: isSurah
                                ? 'Ayat ${_resolvedAyahNumber(current, pos, activeAyahCount)} dari $activeAyahCount'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),

                  // Transport Controls
                  PlayerControls(
                    playing: player.playing,
                    shuffleOn: state.shuffle,
                    repeatOne: state.repeat != RepeatMode.off,
                    onShuffle: player.toggleShuffle,
                    onPlayPause: player.togglePlay,
                    onRepeat: player.cycleRepeat,
                    onPrevious: player.previous,
                    onNext: player.next,
                  ),
                  const Gap(16),

                  // Utility dock
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runAlignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniActionChip(
                        label: '${state.speed}×',
                        semanticLabel: 'Kecepatan putar ${state.speed} kali',
                        onTap: () => showSpeedSheet(context, player),
                      ),
                      _MiniActionChip(
                        icon: AppIcons.timer,
                        label: state.sleepAtEndOfItem
                            ? 'Akhir item'
                            : state.sleepAt != null
                                ? 'Timer aktif'
                                : 'Timer',
                        active:
                            state.sleepAt != null || state.sleepAtEndOfItem,
                        semanticLabel: 'Timer tidur',
                        onTap: () => showSleepTimerSheet(context, player),
                      ),
                      _MiniActionChip(
                        icon: AppIcons.scroll,
                        label: 'Antrean (${state.queue.length})',
                        semanticLabel: 'Buka antrean putar',
                        onTap: () => showQueueSheet(context, player),
                      ),
                    ],
                  ),
                  const Gap(14),

                  // Selector Qari, Surat, Ayat
                  PlaybackPositionBuilder(
                    positionListenable: player.positionListenable,
                    builder: (context, pos) {
                      final resolvedAyah = _resolvedAyahNumber(
                        current,
                        pos,
                        activeAyahCount,
                      );
                      return PlaybackSelectorCard(
                        qariName: activeQariName,
                        qariAvatar: activeQari.photo == null
                            ? null
                            : ClipOval(
                                child: Image(
                                  image: ResizeImage.resizeIfNeeded(
                                    132,
                                    null,
                                    activeQari.photo!,
                                  ),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  alignment: activeQari.photoAlignment,
                                  excludeFromSemantics: true,
                                ),
                              ),
                        surahName: activeSurahName,
                        ayahNumber: resolvedAyah,
                        onQariTap: () => _pickQari(player),
                        onSurahTap: () => _pickSurah(player),
                        onAyahTap: activeSurahNumber > 0
                            ? () => _pickAyah(
                                  player,
                                  activeSurahNumber,
                                  activeSurahName,
                                  activeAyahCount,
                                  resolvedAyah,
                                )
                            : () {},
                      );
                    },
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

class _MiniActionChip extends StatelessWidget {
  const _MiniActionChip({
    this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.active = false,
  });

  final AppIcons? icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: AppSurface(
        color: active ? palette.accentSoft : palette.surface,
        borderColor: active ? palette.borderAccent : palette.border,
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(
                icon!,
                size: 13,
                color: active ? palette.accentLight : palette.textMuted,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: active ? palette.accentLight : palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
