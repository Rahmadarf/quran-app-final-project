import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pill_button.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../player/application/player_controller.dart';
import '../../player/presentation/mini_player.dart';
import '../../player/presentation/qari_picker_sheet.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/ayah.dart';
import '../../quran/domain/surah.dart';
import '../application/reader_controller.dart';
import '../domain/reader_settings.dart';
import 'ayah_actions_sheet.dart';
import 'ayah_tile.dart';
import 'basmalah_header.dart';
import 'display_settings_sheet.dart';
import 'mushaf_view.dart';
import 'surah_header_card.dart';
import 'sync_status_pill.dart';
import 'tafsir_sheet.dart';

/// Layar Reader Al-Qur'an: mode Terjemahan & Mushaf, Basmalah sesuai aturan,
/// SyncEngine Mode A & B, penanda, dan lembar tafsir (docs/06).
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    super.key,
    this.surahNumber = 55,
    this.initialAyah,
  });

  final int surahNumber;
  final int? initialAyah;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
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

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  bool _loadedOnce = false;
  bool _manualScrolling = false;
  int? _lastAutoScrolledAyah;
  late int _selectedAyah = widget.initialAyah ?? 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      final reader = ReaderScope.read(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(reader.loadSurah(widget.surahNumber));
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyForAyah(int number) =>
      _ayahKeys.putIfAbsent(number, () => GlobalKey());

  void _scrollToAyah(int ayahNumber) {
    final ctx = _ayahKeys[ayahNumber]?.currentContext;
    if (ctx == null) return;
    final jumpDistance = (_lastAutoScrolledAyah ?? ayahNumber) - ayahNumber;
    final animate = jumpDistance.abs() < 20;
    _lastAutoScrolledAyah = ayahNumber;

    Scrollable.ensureVisible(
      ctx,
      alignment: 0.28,
      duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _pickQari(
    ReaderController reader,
    PlayerController player,
    Surah surah,
  ) async {
    final current = _qaris.firstWhere(
      (q) => q.id == player.selectedQariId,
      orElse: () => _qaris.first,
    );
    final picked = await showQariPicker(
      context,
      options: _qaris,
      selected: current,
    );
    if (picked != null && mounted) {
      await reader.playFromAyah(
        player,
        surah,
        _selectedAyah,
        qariId: picked.id,
        qariName: picked.name,
      );
    }
  }

  void _showSurahDescription(Surah surah) {
    showAppBottomSheet<void>(
      context,
      title: 'Tentang ${surah.latinName}',
      subtitle: '${surah.revelation.label} · ${surah.ayahCount} ayat',
      builder: (_, _) => Text(
        surah.descriptionPlain.isEmpty
            ? 'Tidak ada deskripsi tambahan.'
            : surah.descriptionPlain,
        style: AppTextStyles.custom(
          size: 14,
          lineHeight: 22,
          color: AppColors.sheetText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reader = ReaderScope.of(context);
    final player = PlayerScope.of(context);
    final surah = reader.currentSurah;
    final settings = reader.settings;

    final palette = AppThemeScope.paletteOf(context);
    final screenClass = AppBreakpoints.of(context);
    final hPad = AppBreakpoints.horizontalPadding(screenClass);

    return ColoredBox(
      color: palette.background,
      child: Column(
        children: [
          AppTopBar(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: IconCircleButton(
              icon: AppIcons.arrowBack,
              semanticLabel: 'Kembali',
              size: 40,
              iconSize: 18,
              iconColor: AppColors.textMuted,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            center: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surah != null
                      ? 'Surah ${surah.latinName}'
                      : 'Surat ${widget.surahNumber}',
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
                Text(
                  surah != null
                      ? 'Surat ke-${surah.number} • ${surah.ayahCount} Ayat'
                      : 'Memuat surat...',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.accentLight,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconCircleButton(
                  icon: AppIcons.textSize,
                  semanticLabel: 'Pengaturan tampilan Reader',
                  size: 40,
                  iconSize: 16,
                  iconColor: AppColors.accentLight,
                  onTap: () => showDisplaySettingsSheet(
                    context,
                    reader: reader,
                    player: player,
                    currentActiveAyah: _selectedAyah,
                  ),
                ),
                const SizedBox(width: 4),
                const AvatarRing(
                  image: AssetImage('assets/images/avatars/aisyah.png'),
                  size: 32,
                  semanticLabel: 'Foto profil Aisyah',
                ),
              ],
            ),
          ),
          if (reader.isDetailOffline || reader.isDetailStale)
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
              child: StatusBanner(
                kind: reader.isDetailOffline
                    ? StatusBannerKind.offline
                    : StatusBannerKind.stale,
                message: reader.isDetailOffline
                    ? 'Mode offline — menampilkan ayat tersimpan'
                    : 'Menampilkan ayat tersimpan dari cache',
                actionLabel: reader.isDetailOffline ? 'Coba lagi' : 'Segarkan',
                onAction: () =>
                    reader.loadSurah(widget.surahNumber, forceRefresh: true),
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth(screenClass),
                ),
                child: _buildBody(context, reader, player, surah, settings),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReaderController reader,
    PlayerController player,
    Surah? surah,
    ReaderSettings settings,
  ) {
    if (reader.loadingSurahDetail && surah == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          SkeletonBox(height: 180, radius: 12),
          SizedBox(height: 16),
          SkeletonBox(height: 130, radius: 12),
          SizedBox(height: 10),
          SkeletonBox(height: 130, radius: 12),
        ],
      );
    }

    if (reader.surahDetailError != null && surah == null) {
      return ErrorState(
        message: reader.surahDetailError!.userMessage,
        onRetry: () => reader.loadSurah(widget.surahNumber, forceRefresh: true),
      );
    }

    if (surah == null) {
      return const SizedBox.shrink();
    }

    return PlaybackPositionBuilder(
      positionListenable: player.positionListenable,
      builder: (context, pos) {
        final sync = reader.syncEngine.resolve(
          surah: surah,
          current: player.state.current,
          pos: pos,
        );
        final activeAyah = sync.activeAyah ?? _selectedAyah;

        if (sync.activeAyah != null &&
            sync.activeAyah != _lastAutoScrolledAyah &&
            settings.autoScroll &&
            !_manualScrolling &&
            settings.mode == ReaderMode.translation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToAyah(sync.activeAyah!);
          });
        }

        final basmalah = reader.basmalahAyah;
        final showBasmalah = reader.shouldShowBasmalahHeader(surah.number) &&
            basmalah != null;

        return Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null &&
                      !_manualScrolling) {
                    setState(() => _manualScrolling = true);
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: 2 +
                      (showBasmalah ? 1 : 0) +
                      (settings.mode == ReaderMode.mushaf
                          ? 1
                          : surah.ayat.length),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => _showSurahDescription(surah),
                          child: SurahHeaderCard(
                            metadata:
                                'Surat ke-${surah.number} • ${surah.ayahCount} Ayat • ${surah.revelation.label}',
                            arabicName: surah.arabicName,
                            latinName: surah.latinName,
                            meaning: '(${surah.meaning})',
                            qariName: _qaris
                                .firstWhere(
                                  (q) => q.id == player.selectedQariId,
                                  orElse: () => _qaris.first,
                                )
                                .name,
                            transliterationOn: settings.showTransliteration,
                            repeatOn: player.repeatOne,
                            onQariTap: () => _pickQari(reader, player, surah),
                            onTransliterationTap: () => reader.updateSettings(
                              settings.copyWith(
                                showTransliteration:
                                    !settings.showTransliteration,
                              ),
                            ),
                            onTextSizeTap: () => showDisplaySettingsSheet(
                              context,
                              reader: reader,
                              player: player,
                              currentActiveAyah: activeAyah,
                            ),
                            onRepeatTap: player.toggleRepeatOne,
                          ),
                        ),
                      );
                    }

                    var cursor = 1;
                    if (showBasmalah) {
                      if (index == cursor) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: BasmalahHeader(
                            arabic: basmalah.arabic,
                            translation: basmalah.translation,
                          ),
                        );
                      }
                      cursor++;
                    }

                    if (settings.mode == ReaderMode.mushaf) {
                      if (index == cursor) {
                        return MushafView(
                          ayat: surah.ayat,
                          arabicFontSize: settings.arabicFontSize,
                          activeAyah: sync.activeAyah,
                          onAyahTap: (ayah) {
                            setState(() => _selectedAyah = ayah.number);
                            showAyahActionsSheet(
                              context,
                              surah: surah,
                              ayah: ayah,
                              bookmarked:
                                  reader.isBookmarked(surah.number, ayah.number),
                              onPlayFromHere: () => reader.playFromAyah(
                                player,
                                surah,
                                ayah.number,
                              ),
                              onToggleBookmark: () =>
                                  reader.toggleBookmark(surah, ayah),
                              onOpenTafsir: () => showTafsirSheet(
                                context,
                                reader: reader,
                                surah: surah,
                                ayahNumber: ayah.number,
                              ),
                            );
                          },
                        );
                      }
                      cursor++;
                    } else {
                      final ayahIdx = index - cursor;
                      if (ayahIdx >= 0 && ayahIdx < surah.ayat.length) {
                        final ayah = surah.ayat[ayahIdx];
                        return Padding(
                          key: _keyForAyah(ayah.number),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildAyahTile(
                            context,
                            reader,
                            player,
                            surah,
                            ayah,
                            activeAyah,
                            sync.activeAyah != null,
                            settings,
                          ),
                        );
                      }
                      cursor += surah.ayat.length;
                    }

                    // Navigasi surat sebelumnya / berikutnya di dasar daftar.
                    return _SurahNavigationRow(surah: surah);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  SyncStatusPill(
                    label: sync.isEstimated ||
                            settings.syncMode == SyncMode.fullSurah
                        ? 'Sorotan perkiraan'
                        : 'Sinkronisasi Ayat Otomatis',
                  ),
                  if (_manualScrolling && sync.activeAyah != null)
                    PillButton(
                      label: 'Kembali ke ayat ${sync.activeAyah}',
                      style: PillButtonStyle.highlight,
                      height: 30,
                      onTap: () {
                        setState(() => _manualScrolling = false);
                        _scrollToAyah(sync.activeAyah!);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                8,
                0,
                8,
                8 + MediaQuery.paddingOf(context).bottom,
              ),
              child: _miniPlayer(context, reader, player, surah, activeAyah),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAyahTile(
    BuildContext context,
    ReaderController reader,
    PlayerController player,
    Surah surah,
    Ayah ayah,
    int activeAyah,
    bool syncedFromPlayer,
    ReaderSettings settings,
  ) {
    final isActive = ayah.number == activeAyah;
    final isThisPlaying = isActive && syncedFromPlayer && player.playing;
    return AyahTile(
      number: ayah.number,
      arabic: ayah.arabic,
      arabicFontSize: settings.arabicFontSize,
      transliteration: settings.showTransliteration &&
              ayah.transliteration.trim().isNotEmpty
          ? ayah.transliteration.trim()
          : null,
      translation: settings.showTranslation ? ayah.translation : '',
      active: isActive,
      playing: isThisPlaying,
      bookmarked: reader.isBookmarked(surah.number, ayah.number),
      playbackLabel:
          isThisPlaying ? 'Memutar ${formatClock(player.elapsedSeconds)}' : null,
      onPlay: () {
        setState(() {
          _selectedAyah = ayah.number;
          _manualScrolling = false;
        });
        if (isThisPlaying) {
          player.pause();
        } else {
          reader.playFromAyah(player, surah, ayah.number);
        }
      },
      onBookmark: () => reader.toggleBookmark(surah, ayah),
      onTafsir: () => showTafsirSheet(
        context,
        reader: reader,
        surah: surah,
        ayahNumber: ayah.number,
      ),
      onCopy: () {
        final text =
            '${ayah.arabic}\n\n${ayah.translation}\n(QS ${surah.latinName}: ${ayah.number})';
        Clipboard.setData(ClipboardData(text: text));
      },
      onShare: () {},
    );
  }

  Widget _miniPlayer(
    BuildContext context,
    ReaderController reader,
    PlayerController player,
    Surah surah,
    int activeAyah,
  ) {
    return MiniPlayer(
      leading: MiniPlayerLeading.text(_arabicDigits(activeAyah)),
      title: '${surah.latinName} : Ayat $activeAyah',
      subtitle: player.state.current?.subtitle ?? 'Misyari Rasyid Al-Afasi',
      progress: activeAyah / surah.ayahCount.clamp(1, 999),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.player),
      actions: [
        IconCircleButton(
          icon: AppIcons.previous,
          semanticLabel: 'Ayat sebelumnya',
          size: 32,
          iconSize: 12,
          iconColor: AppColors.textMuted,
          onTap: activeAyah > 1
              ? () {
                  final prev = activeAyah - 1;
                  setState(() => _selectedAyah = prev);
                  reader.playFromAyah(player, surah, prev);
                }
              : null,
        ),
        IconCircleButton(
          icon: player.playing ? AppIcons.pause : AppIcons.play,
          semanticLabel: player.playing ? 'Jeda' : 'Putar',
          style: IconCircleStyle.primary,
          size: 40,
          iconSize: 14,
          onTap: () {
            if (player.state.current?.surahNumber == surah.number) {
              player.togglePlay();
            } else {
              reader.playFromAyah(player, surah, activeAyah);
            }
          },
        ),
        IconCircleButton(
          icon: AppIcons.next,
          semanticLabel: 'Ayat berikutnya',
          size: 32,
          iconSize: 12,
          iconColor: AppColors.textMuted,
          onTap: activeAyah < surah.ayahCount
              ? () {
                  final next = activeAyah + 1;
                  setState(() => _selectedAyah = next);
                  reader.playFromAyah(player, surah, next);
                }
              : null,
        ),
      ],
    );
  }

  static String _arabicDigits(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return '$n'.split('').map((c) => digits[int.parse(c)]).join();
  }
}

class _SurahNavigationRow extends StatelessWidget {
  const _SurahNavigationRow({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final prev = surah.previousSurah;
    final next = surah.nextSurah;
    if (prev == null && next == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (prev != null)
            Expanded(
              child: AppButton(
                label: '← ${prev.latinName}',
                onTap: () => Navigator.of(context).pushReplacementNamed(
                  AppRoutes.readerFor(prev.number),
                ),
              ),
            ),
          if (prev != null && next != null) const SizedBox(width: 8),
          if (next != null)
            Expanded(
              child: AppButton(
                label: '${next.latinName} →',
                style: AppButtonStyle.primary,
                onTap: () => Navigator.of(context).pushReplacementNamed(
                  AppRoutes.readerFor(next.number),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
