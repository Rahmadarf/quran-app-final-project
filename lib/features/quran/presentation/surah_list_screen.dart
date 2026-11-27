import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/avatar.dart';
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

/// Daftar 114 surat dari API equran.id dengan pencarian, filter Mekah/Madinah,
/// dan kartu "Lanjutkan membaca" (docs/06 §2.1).
class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  String _query = '';
  int _filterIndex = 0; // 0: Semua, 1: Mekah, 2: Madinah
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
            leading: const AvatarRing(
              image: AssetImage('assets/images/avatars/aisyah.png'),
              semanticLabel: 'Foto profil Aisyah',
            ),
            center: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Al-Qur'an",
                  style: AppTextStyles.heading.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                Text(
                  '114 Surat · Terjemahan & Audio',
                  style: AppTextStyles.micro.copyWith(
                    color: palette.accentLight,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          if (reader.isSurahsOffline || reader.isSurahsStale)
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
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
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
          child: Column(
            children: [
              AppSearchField(
                hint: 'Cari nama surat, arti, atau nomor (mis. 36)...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 10),
              FilterChipBar(
                padding: EdgeInsets.zero,
                items: const [
                  FilterChipItem('Semua'),
                  FilterChipItem('Makkiyah'),
                  FilterChipItem('Madinah'),
                ],
                selectedIndex: _filterIndex,
                onSelected: (i) => setState(() => _filterIndex = i),
              ),
            ],
          ),
        ),
        if (lastRead != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Pressable(
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.readerFor(lastRead.surahNumber, ayah: lastRead.ayahNumber),
              ),
              semanticLabel:
                  'Lanjutkan membaca ${lastRead.surahName} ayat ${lastRead.ayahNumber}',
              child: AppSurface(
                color: AppColors.surfaceActive,
                borderColor: AppColors.accentAt(0.5),
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const AppIcon(
                      AppIcons.bookmarkFilled,
                      size: 16,
                      color: AppColors.accentLight,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lanjutkan membaca',
                            style: AppTextStyles.micro.copyWith(
                              color: AppColors.accentLight,
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            '${lastRead.surahName} · Ayat ${lastRead.ayahNumber}',
                            style: AppTextStyles.cardTitle,
                          ),
                        ],
                      ),
                    ),
                    const AppIcon(
                      AppIcons.chevronRight,
                      size: 12,
                      color: AppColors.accentLight,
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
              child: _buildBody(context, reader, player, allSurahs, visible),
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
  ) {
    if (reader.loadingSurahs && allSurahs.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: 8,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, _) => const SkeletonBox(height: 60, radius: 14),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
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
