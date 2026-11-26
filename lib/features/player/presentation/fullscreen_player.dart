import 'dart:async';

import 'package:flutter/widgets.dart' hide RepeatMode;

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/utils/duration_format.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pill_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/player_controller.dart';
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

/// Fullscreen Player: ayat bergaya lirik, bilah geser, kontrol utama, serta
/// pemilih qari, surat, kecepatan, timer tidur, dan antrean (docs/05 §1).
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

  Future<void> _pickQari(PlayerController player) async {
    final result =
        await showQariPicker(context, options: _qaris, selected: _qari);
    if (result != null && mounted) {
      setState(() => _qari = result);
      unawaited(
        player.playSurah(
          _surah.number,
          qariId: result.id,
          qariName: result.name,
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

    final result =
        await showSurahPicker(context, options: options, selected: _surah);
    if (result != null && result.number != _surah.number && mounted) {
      setState(() {
        _surah = result;
        _ayah = 1;
      });
      unawaited(
        player.playSurah(
          result.number,
          qariId: _qari.id,
          qariName: _qari.name,
        ),
      );
    }
  }

  Future<void> _pickAyah() async {
    final result = await showAyahPicker(
      context,
      surahName: _surah.name,
      ayahCount: _surah.ayahCount,
      current: _ayah,
    );
    if (result != null && mounted) setState(() => _ayah = result);
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final state = player.state;
    final current = state.current;

    final activeSurahNumber = current?.surahNumber ?? _surah.number;
    final activeSurahName =
        (current?.meta['surahLatinName'] as String?) ?? _surah.name;
    final activeAyahCount = current?.ayahCount ?? _surah.ayahCount;
    final activeQariName = current?.subtitle ?? _qari.name;
    final displayTitle = current?.title ?? 'Surat ${_surah.name}';
    final isSurah = current == null || current.kind.hasReader;

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
                      state.queueSource?.toUpperCase() ?? 'MEMUTAR SURAT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.micro.copyWith(
                        color: AppColors.accentLight,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      isSurah ? activeSurahName : displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    if (isSurah) ...[
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
                  ],
                ),
              ),
              if (state.phase == PlayerPhase.error && state.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: AppSurface(
                    color: const Color(0x33EF4444),
                    borderColor: const Color(0x66EF4444),
                    radius: 12,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.error!.message,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPlayerTitle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          label: 'Coba lagi',
                          height: 32,
                          onTap: player.retry,
                        ),
                        if (state.error!.canSkip) ...[
                          const SizedBox(width: 6),
                          AppButton(
                            label: 'Lewati',
                            height: 32,
                            onTap: player.next,
                          ),
                        ],
                      ],
                    ),
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
                                displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.custom(
                                  size: 22,
                                  lineHeight: 33,
                                  weight: FontWeight.w700,
                                  color: AppColors.textPlayerTitle,
                                  letterSpacing: -0.55,
                                ),
                              ),
                              Text(
                                '$activeQariName · ${current?.source.name == 'local' ? 'Lokal' : 'Stream'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                            const SizedBox(height: 4),
                            PlayerTimeline(
                              elapsed: formatDuration(pos.position),
                              remaining:
                                  formatRemaining(pos.position, pos.duration),
                              centerLabel: isSurah
                                  ? 'Ayat ${_ayah.clamp(1, activeAyahCount)} dari $activeAyahCount'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(height: 16),
                    PlaybackSelectorCard(
                      qariName: activeQariName,
                      qariAvatar: _qari.photo == null
                          ? null
                          : ClipOval(
                              child: Image(
                                image: _qari.photo!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                alignment: _qari.photoAlignment,
                                excludeFromSemantics: true,
                              ),
                            ),
                      surahName: activeSurahName,
                      ayahNumber: _ayah.clamp(1, activeAyahCount),
                      onQariTap: () => _pickQari(player),
                      onSurahTap: () => _pickSurah(player),
                      onAyahTap: activeSurahNumber > 0 ? _pickAyah : () {},
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
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: AppSurface(
        color: active ? AppColors.surfaceStrong : AppColors.surfaceAt(0.7),
        borderColor: active ? AppColors.accent : AppColors.borderAt(0.5),
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(
                icon!,
                size: 13,
                color: active ? AppColors.accentLight : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.micro.copyWith(
                color: active ? AppColors.accentLight : AppColors.textBody,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
