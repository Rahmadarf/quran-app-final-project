import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/action_row_card.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/filter_chip_bar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/media_row.dart';
import '../../../shared/widgets/section_header.dart';
import '../../history/presentation/history_row.dart';
import 'bookmark_card.dart';

/// Pustaka: playlist tersimpan, riwayat tilawah, dan penanda ayat.
///
/// Chip di atas memilih bagian yang ditampilkan. Data di file ini adalah
/// contoh dari Figma.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const int _all = 0, _playlist = 1, _download = 2, _history = 3, _mark = 4;

  int _filter = _all;

  bool _show(int section) => _filter == _all || _filter == section;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTopBar(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: const AvatarRing(
            image: AssetImage('assets/images/avatars/aisyah.png'),
            semanticLabel: 'Foto profil Aisyah',
          ),
          center: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RUANG SIMPAN PERSONAL',
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  letterSpacing: 0.9,
                ),
              ),
              Text('Pustaka Saya', style: AppTextStyles.heading),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconCircleButton(
                icon: AppIcons.add,
                semanticLabel: 'Buat playlist baru',
                style: IconCircleStyle.tonal,
                size: 36,
                iconSize: 14,
                iconColor: AppColors.accentLight,
                onTap: () {},
              ),
              const SizedBox(width: 6),
              IconCircleButton(
                icon: AppIcons.sort,
                semanticLabel: 'Urutkan',
                style: IconCircleStyle.tonal,
                size: 36,
                iconSize: 14,
                iconColor: AppColors.skyLabel,
                onTap: () {},
              ),
              const SizedBox(width: 2),
              IconCircleButton(
                icon: AppIcons.search,
                semanticLabel: 'Cari di pustaka',
                size: 36,
                iconSize: 15,
                iconColor: AppColors.accentLight,
                onTap: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSearchField(
                  hint: 'Cari surat, qari, atau playlist tersimpan...',
                ),
                const SizedBox(height: 16),
                FilterChipBar(
                  padding: EdgeInsets.zero,
                  items: const [
                    FilterChipItem('Semua'),
                    FilterChipItem('Playlist', count: 4),
                    FilterChipItem('Unduhan', count: 6),
                    FilterChipItem('Riwayat'),
                    FilterChipItem('Penanda', count: 12),
                  ],
                  selectedIndex: _filter,
                  onSelected: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: 16),
                if (_show(_playlist) || _filter == _download) ..._playlistSection(),
                if (_show(_history)) ..._historySection(),
                if (_show(_mark)) ..._bookmarkSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _playlistSection() {
    final onlyOffline = _filter == _download;
    return [
      if (_filter == _all || _filter == _playlist) ...[
        ActionRowCard(
          icon: AppIcons.playlistAdd,
          title: 'Buat Playlist Baru',
          subtitle: 'Kumpulkan tilawah, wirid & dzikir favoritmu',
          onTap: () {},
        ),
        const SizedBox(height: 24),
      ],
      SectionHeader(
        title: onlyOffline ? 'Tersedia Offline' : 'Playlist Tersimpan',
        count: onlyOffline ? 1 : 4,
        titleStyle: AppTextStyles.heading.copyWith(fontSize: 16),
        trailingLabel: 'Lihat Semua',
        onTrailingTap: () {},
      ),
      const SizedBox(height: 10),
      if (!onlyOffline) ...[
        MediaRow(
          leading: const MediaThumb(
            image: AssetImage('assets/images/covers/favorit-rutin.png'),
          ),
          title: 'Surat Favorit Rutin',
          favorite: true,
          subtitle: 'Dibuat oleh Aisyah • 12 Surat',
          tagline: "Ar-Rahman, Al-Waqi'ah, Al-Mulk",
          onMore: () {},
        ),
        const SizedBox(height: 10),
      ],
      MediaRow(
        leading: const MediaThumb(
          image: AssetImage('assets/images/covers/masjid-petang.png'),
          overlayIcon: AppIcons.offlineDone,
        ),
        title: 'Dzikir Pagi & Petang',
        offline: true,
        subtitle: "Al-Ma'tsurat Lengkap • 8 Audio",
        tagline: "Syaikh Sa'ad Al-Ghamidi",
        onMore: () {},
      ),
      if (!onlyOffline) ...[
        const SizedBox(height: 10),
        MediaRow(
          leading: const MediaThumb(
            image: AssetImage('assets/images/covers/al-kahfi.png'),
          ),
          title: 'Murattal Pengantar Tidur',
          subtitle: 'Sajdah, Al-Insan, Al-Mulk • 45 Menit',
          tagline: 'Nada Hening Tenang • Audio 3D',
          onMore: () {},
        ),
        const SizedBox(height: 10),
        MediaRow(
          leading: const MediaThumb(icon: AppIcons.podcast),
          title: 'Tadabbur & Kajian Pilihan',
          subtitle: '5 Episode Podcast Audio',
          tagline: 'Makna Keindahan Surat Al-Fatihah',
          onMore: () {},
        ),
      ],
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _historySection() => [
        SectionHeader(
          title: 'Riwayat Tilawah Terakhir',
          titleStyle: AppTextStyles.heading.copyWith(fontSize: 16),
          trailingLabel: 'Lihat lebih banyak',
          onTrailingTap: () {},
        ),
        const SizedBox(height: 10),
        HistoryRow(
          surahNumber: 55,
          title: 'Surah Ar-Rahman (Ayat 1–78)',
          qariName: 'Misyari Rasyid',
          when: 'Kemarin, 21:15',
          onPlay: () {},
        ),
        const SizedBox(height: 8),
        HistoryRow(
          surahNumber: 18,
          title: 'Surah Al-Kahfi',
          qariName: 'Abdurrahman As-Sudais',
          when: 'Hari Jumat',
          onPlay: () {},
        ),
        const SizedBox(height: 24),
      ];

  List<Widget> _bookmarkSection() => [
        SectionHeader(
          title: 'Penanda Ayat Tersimpan',
          count: 12,
          titleStyle: AppTextStyles.heading.copyWith(fontSize: 16),
          trailingLabel: 'Lihat Semua',
          onTrailingTap: () {},
        ),
        const SizedBox(height: 10),
        BookmarkCard(
          reference: 'QS. Ar-Rahman : 13',
          page: 'Halaman 531',
          arabic: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
          translation: 'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
          onListen: () {},
          onRemove: () {},
        ),
        const SizedBox(height: 10),
        BookmarkCard(
          reference: "QS. Ar-Ra'd : 28",
          page: 'Halaman 252',
          arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
          translation: 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
          onListen: () {},
          onRemove: () {},
        ),
      ];
}
