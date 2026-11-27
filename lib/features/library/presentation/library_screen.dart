import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/filter_chip_bar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/media_row.dart';
import '../../../shared/widgets/section_header.dart';
import '../../history/presentation/history_row.dart';
import '../../player/application/player_providers.dart';
import 'bookmark_card.dart';

/// Pustaka dual-mode sesuai Figma `05 — Pustaka (Library)`.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const int _all = 0, _playlist = 1, _download = 2, _mark = 3;

  int _filter = _all;

  bool _show(int section) => _filter == _all || _filter == section;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final player = PlayerScope.read(context);
    void openCollection() =>
        Navigator.of(context).pushNamed(AppRoutes.collection);
    void openReader(int surah, {int? ayah}) => Navigator.of(context)
        .pushNamed(AppRoutes.readerFor(surah, ayah: ayah));

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
                  'Pustaka Saya',
                  style: AppTextStyles.display
                      .copyWith(color: palette.textPrimary),
                ),
                Text(
                  'Playlist, Unduhan Offline & Penanda',
                  style:
                      AppTextStyles.caption.copyWith(color: palette.textMuted),
                ),
              ],
            ),
            trailing: IconCircleButton(
              icon: AppIcons.add,
              semanticLabel: 'Buat playlist baru',
              style: IconCircleStyle.primary,
              size: 38,
              iconSize: 16,
              onTap: openCollection,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilterChipBar(
                    padding: EdgeInsets.zero,
                    items: const [
                      FilterChipItem('Semua'),
                      FilterChipItem('Playlist'),
                      FilterChipItem('Unduhan'),
                      FilterChipItem('Penanda'),
                    ],
                    selectedIndex: _filter,
                    onSelected: (i) => setState(() => _filter = i),
                  ),
                  const Gap(18),
                  if (_show(_playlist) || _filter == _download) ...[
                    SectionHeader(
                      title: _filter == _download
                          ? 'Tersedia Offline'
                          : 'Playlist & Unduhan',
                      trailingLabel: 'Lihat semua',
                      onTrailingTap: openCollection,
                    ),
                    const Gap(6),
                    if (_filter != _download)
                      MediaRow(
                        leading: const MediaThumb(
                          image: AssetImage(
                            'assets/images/covers/favorit-rutin.png',
                          ),
                        ),
                        title: 'Surat Favorit Rutin',
                        subtitle: '12 Surat · Aisyah',
                        onTap: openCollection,
                        onMore: openCollection,
                      ),
                    MediaRow(
                      leading: const MediaThumb(
                        image: AssetImage(
                          'assets/images/covers/masjid-petang.png',
                        ),
                      ),
                      title: 'Dzikir Pagi & Petang',
                      offline: true,
                      subtitle: '8 Audio · 24 MB Tersimpan Offline',
                      onTap: openCollection,
                      onMore: openCollection,
                    ),
                    MediaRow(
                      leading: const MediaThumb(
                        image: AssetImage('assets/images/covers/al-kahfi.png'),
                      ),
                      title: 'Murattal Pengantar Tidur',
                      offline: true,
                      subtitle: 'Al-Mulk, As-Sajdah · 45 mnt',
                      onTap: () => player.playSurah(67),
                      onMore: openCollection,
                    ),
                    const Gap(22),
                  ],
                  if (_show(_mark)) ...[
                    SectionHeader(
                      title: 'Penanda Ayat',
                      trailingLabel: 'Lihat semua',
                      onTrailingTap: () => openReader(55, ayah: 13),
                    ),
                    const Gap(10),
                    BookmarkCard(
                      reference: 'QS. Ar-Rahman : 13',
                      page: 'Juz 27 · Hal. 531',
                      arabic: 'فَبِاَيِّ اٰلَاۤءِ رَبِّكُمَا تُكَذِّبٰنِ',
                      translation:
                          'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
                      onTap: () => openReader(55, ayah: 13),
                      onListen: () => player.playSurah(55),
                      onRemove: () {},
                    ),
                    const Gap(22),
                  ],
                  if (_filter == _all) ...[
                    const SectionHeader(title: 'Riwayat Terakhir'),
                    const Gap(6),
                    HistoryRow(
                      surahNumber: 55,
                      title: 'Surah Ar-Rahman',
                      qariName: 'Misyari Rasyid',
                      when: 'Kemarin, 21:15',
                      onTap: () => openReader(55),
                      onPlay: () => player.playSurah(55, qariId: '05'),
                    ),
                    HistoryRow(
                      surahNumber: 18,
                      title: 'Surah Al-Kahfi',
                      qariName: 'Abdurrahman As-Sudais',
                      when: 'Jumat',
                      onTap: () => openReader(18),
                      onPlay: () => player.playSurah(18, qariId: '03'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
