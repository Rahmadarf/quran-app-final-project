import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/filter_chip_bar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../player/application/player_controller.dart';
import '../application/quran_providers.dart';
import '../domain/surah.dart';
import 'surah_row.dart';

/// Daftar 114 surat dual-mode sesuai Figma `02 — Daftar Surat (Al-Qur'an)`.
class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  String _query = '';
  int _filterIndex = 0; // 0: Semua, 1: Makkiyah, 2: Madaniyah
  bool _requestedInitial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedInitial) {
      _requestedInitial = true;
      final reader = ReaderScope.read(context);
      if (reader.surahs.isEmpty && !reader.loadingSurahs) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(reader.loadSurahs());
        });
      }
    }
  }

  List<Surah> _filtered(List<Surah> all) {
    final q = _query.trim().toLowerCase();
    return all.where((s) {
      if (_filterIndex == 1 && s.revelation != Revelation.makkiyah) {
        return false;
      }
      if (_filterIndex == 2 && s.revelation != Revelation.madaniyah) {
        return false;
      }
      if (q.isEmpty) return true;
      return s.latinName.toLowerCase().contains(q) ||
          s.meaning.toLowerCase().contains(q) ||
          s.number.toString() == q;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final reader = ReaderScope.of(context);
    final player = PlayerScope.of(context);
    final allSurahs = reader.surahs;
    final visible = _filtered(allSurahs);
    final lastRead = reader.lastRead;
    final screenClass = AppBreakpoints.of(context);
    final hPad = AppBreakpoints.horizontalPadding(screenClass);
    final palette = AppThemeScope.paletteOf(context);

    return ColoredBox(
      color: palette.background,
      child: Column(
        children: [
          AppTopBar(
            showBottomBorder: false,
            center: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Al-Qur'an",
                  style: AppTextStyles.display
                      .copyWith(color: palette.textPrimary),
                ),
                Text(
                  '114 Surat · 6.236 Ayat',
                  style:
                      AppTextStyles.caption.copyWith(color: palette.textMuted),
                ),
              ],
            ),
            trailing: Pressable(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.player),
              semanticLabel: 'Qari aktif ${player.selectedQariName}',
              child: AppSurface(
                color: palette.surface,
                borderColor: palette.border,
                radius: 999,
                padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: Image(
                        image: ResizeImage.resizeIfNeeded(
                          72,
                          null,
                          const AssetImage(
                            'assets/images/qari/misyari-rasyid-al-afasi.webp',
                          ),
                        ),
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                    const Gap(7),
                    Text(
                      player.selectedQariName.split(' ').last,
                      style: AppTextStyles.label
                          .copyWith(color: palette.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (reader.isSurahsOffline || reader.isSurahsStale)
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 6),
              child: StatusBanner(
                kind: reader.isSurahsOffline
                    ? StatusBannerKind.offline
                    : StatusBannerKind.stale,
                message: reader.isSurahsOffline
                    ? 'Mode offline — menampilkan daftar surat tersimpan'
                    : 'Menampilkan data tersimpan dari cache',
                actionLabel: reader.isSurahsOffline ? 'Coba lagi' : 'Segarkan',
                onAction: () => reader.loadSurahs(forceRefresh: true),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 10),
            child: Column(
              children: [
                AppSearchField(
                  hint: 'Cari nama surat, arti, atau nomor…',
                  onChanged: (v) => setState(() => _query = v),
                ),
                const Gap(12),
                FilterChipBar(
                  padding: EdgeInsets.zero,
                  items: const [
                    FilterChipItem('Semua'),
                    FilterChipItem('Makkiyah'),
                    FilterChipItem('Madaniyah'),
                  ],
                  selectedIndex: _filterIndex,
                  onSelected: (i) => setState(() => _filterIndex = i),
                ),
              ],
            ),
          ),
          if (lastRead != null)
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 10),
              child: Pressable(
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.readerFor(
                    lastRead.surahNumber,
                    ayah: lastRead.ayahNumber,
                  ),
                ),
                semanticLabel:
                    'Lanjutkan membaca ${lastRead.surahName} ayat ${lastRead.ayahNumber}',
                child: AppSurface(
                  color: palette.accentSoft,
                  borderColor: palette.borderAccent,
                  radius: 12,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      AppIcon(
                        AppIcons.bookmarkFilled,
                        size: 16,
                        color: palette.accentLight,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LANJUTKAN MEMBACA',
                              style: AppTextStyles.micro
                                  .copyWith(color: palette.accentLight),
                            ),
                            Text(
                              '${lastRead.surahName} · Ayat ${lastRead.ayahNumber}',
                              style: AppTextStyles.cardTitle
                                  .copyWith(color: palette.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      AppIcon(
                        AppIcons.chevronRight,
                        size: 11,
                        color: palette.accentLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth(screenClass),
                ),
                child: _buildBody(
                  context,
                  reader,
                  player,
                  allSurahs,
                  visible,
                  hPad,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic reader,
    PlayerController player,
    List<Surah> allSurahs,
    List<Surah> visible,
    double hPad,
  ) {
    if (reader.loadingSurahs && allSurahs.isEmpty) {
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
        itemCount: 8,
        separatorBuilder: (_, _) => const Gap(10),
        itemBuilder: (_, _) => const SkeletonBox(height: 58, radius: 12),
      );
    }

    if (reader.surahsError != null && allSurahs.isEmpty) {
      return ErrorState(
        message: reader.surahsError!.userMessage,
        onRetry: () => reader.loadSurahs(forceRefresh: true),
      );
    }

    if (visible.isEmpty) {
      return EmptyState(
        icon: AppIcons.search,
        title: 'Surat tidak ditemukan',
        message: 'Tidak ada surat yang cocok dengan "$_query".',
        actionLabel: 'Reset pencarian',
        onAction: () => setState(() {
          _query = '';
          _filterIndex = 0;
        }),
      );
    }

    final activeSurahNo = player.state.current?.surahNumber;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final surah = visible[index];
        final isPlaying = player.playing && activeSurahNo == surah.number;
        return SurahRow(
          surah: surah,
          isPlaying: isPlaying,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.readerFor(surah.number),
          ),
          onPlay: () {
            if (isPlaying) {
              player.pause();
            } else {
              player.playSurah(surah.number);
            }
          },
        );
      },
    );
  }
}
