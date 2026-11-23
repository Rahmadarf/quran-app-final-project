import 'package:flutter/widgets.dart';

import '../app/app_colors.dart';
import '../app/app_text_styles.dart';
import '../features/catalog/presentation/tafsir_card.dart';
import '../features/history/presentation/history_row.dart';
import '../features/library/presentation/bookmark_card.dart';
import '../features/player/presentation/ayah_lyrics_view.dart';
import '../features/player/presentation/ayah_picker_sheet.dart';
import '../features/player/presentation/mini_player.dart';
import '../features/player/presentation/player_controls.dart';
import '../features/player/presentation/playback_selector_card.dart';
import '../features/player/presentation/qari_footer_card.dart';
import '../features/player/presentation/qari_picker_sheet.dart';
import '../features/player/presentation/seek_bar.dart';
import '../features/player/presentation/surah_picker_sheet.dart';
import '../features/reader/presentation/ayah_tile.dart';
import '../features/reader/presentation/basmalah_header.dart';
import '../features/reader/presentation/surah_header_card.dart';
import '../features/reader/presentation/sync_status_pill.dart';
import '../shared/widgets/action_row_card.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_icon.dart';
import '../shared/widgets/app_search_field.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/avatar.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/category_card.dart';
import '../shared/widgets/filter_chip_bar.dart';
import '../shared/widgets/icon_circle_button.dart';
import '../shared/widgets/media_card.dart';
import '../shared/widgets/media_row.dart';
import '../shared/widgets/number_stepper.dart';
import '../shared/widgets/pill_button.dart';
import '../shared/widgets/quote_banner.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/selector_field.dart';
import '../shared/widgets/shelf.dart';

/// Katalog komponen untuk pengembangan: semua widget dengan data contoh dari
/// Figma. Jalankan lewat `lib/dev/gallery_main.dart`. Bukan bagian aplikasi.
class WidgetGallery extends StatefulWidget {
  const WidgetGallery({super.key});

  @override
  State<WidgetGallery> createState() => _WidgetGalleryState();
}

class _WidgetGalleryState extends State<WidgetGallery> {
  int _nav = 0;
  int _chip = 0;
  int _tafsirChip = 0;
  double _seek = 0.24;
  int _stepper = 13;

  static const _avatar = AssetImage('assets/images/avatars/aisyah.png');
  static const _arRahman = AssetImage('assets/images/covers/ar-rahman.png');
  static const _alKahfi = AssetImage('assets/images/covers/al-kahfi.png');
  static const _yasin = AssetImage('assets/images/covers/yasin.png');
  static const _masjid = AssetImage('assets/images/covers/masjid-petang.png');
  static const _qariAfasi =
      AssetImage('assets/images/qari/misyari-rasyid-al-afasi.webp');
  static const _qariSudais =
      AssetImage('assets/images/qari/abdurrahman-as-sudais.webp');
  static const _qariJuhany =
      AssetImage('assets/images/qari/abdullah-al-juhany.webp');
  static const _qariDossari =
      AssetImage('assets/images/qari/ibrahim-al-dossari.webp');
  static const _qariQasim =
      AssetImage('assets/images/qari/abdul-muhsin-al-qasim.webp');
  static const _qariYasser =
      AssetImage('assets/images/qari/yasser-al-dossari.webp');
  static const _starfield =
      AssetImage('assets/images/backgrounds/starfield.png');

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _title('1. Beranda'),
                _home(),
                _title('2. Jelajah'),
                _explore(),
                _title('3. Fullscreen Player'),
                _player(),
                _title('4. Pustaka'),
                _library(),
                _title('5. Quran Reader'),
                _reader(),
                _title('6. Tombol dan lencana'),
                _buttons(),
                _title('7. Pemilih qari, surat, dan ayat'),
                _pickers(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
        child: Text(
          text,
          style: AppTextStyles.custom(
            size: 12,
            lineHeight: 16,
            weight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _home() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTopBar(
          leading: const AvatarRing(
            image: _avatar,
            onlineDot: true,
            semanticLabel: 'Foto profil Aisyah',
          ),
          center: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello Aisyah!', style: AppTextStyles.heading),
              Text(
                'Mari dengarkan tilawah hari ini',
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          trailing: IconCircleButton(
            icon: AppIcons.search,
            semanticLabel: 'Cari tilawah',
            style: IconCircleStyle.outlined,
            iconColor: AppColors.accentLight,
            iconSize: 15,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        SectionHeader(
          title: 'Qari Favorit',
          onChevronTap: () {},
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        const SizedBox(height: 14),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              QariAvatarItem(
                image: _qariAfasi,
                name: 'Al-Afasi',
                selected: true,
              ),
              SizedBox(width: 16),
              QariAvatarItem(image: _qariSudais, name: 'As-Sudais'),
              SizedBox(width: 16),
              QariAvatarItem(image: _qariJuhany, name: 'Al-Juhany'),
              SizedBox(width: 16),
              QariAvatarItem(image: _qariDossari, name: 'I. Al-Dossari'),
              SizedBox(width: 16),
              QariAvatarItem(image: _qariQasim, name: 'Al-Qasim'),
              SizedBox(width: 16),
              QariAvatarItem(image: _qariYasser, name: 'Y. Al-Dosari'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Shelf(
          title: 'Rekomendasi Tilawah & Surat Terkini',
          onSeeAll: () {},
          children: const [
            MediaCard(
              image: _arRahman,
              arabicTitle: 'الرحمن',
              title: 'Surat Ar-Rahman',
              subtitle: 'Misyari Rasyid Al-Afasi',
            ),
            MediaCard(
              image: _alKahfi,
              arabicTitle: 'الكهف',
              pillLabel: 'Jumat',
              title: 'Surat Al-Kahfi',
              subtitle: 'Abdurrahman As-Sudais',
            ),
            MediaCard(
              image: _yasin,
              arabicTitle: 'يس',
              title: 'Surat Yasin',
              subtitle: 'Abdullah Al-Juhany',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Shelf(
          title: 'Dibuat Untuk Kamu',
          onSeeAll: () {},
          children: const [
            MediaCard(
              image: _masjid,
              badgeIcon: AppIcons.sparkle,
              overlayLabel: 'MIX HARIAN',
              title: 'Daily Murattal Mix 1',
              subtitle: 'Al-Afasi, As-Sudais, Al-Juhany',
            ),
            MediaCard(
              image: _alKahfi,
              badgeIcon: AppIcons.adhkar,
              overlayLabel: 'VOCAL-ONLY',
              overlayLabelColor: AppColors.skyLabel,
              title: 'Dzikir Penenang Petang',
              subtitle: 'Vocal-only, tanpa musik',
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: QuoteBanner(
            quote: 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
            reference: "QS. Ar-Ra'd : 28",
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MiniPlayer(
            leading: const MiniPlayerLeading.image(_arRahman),
            title: 'Surat Ar-Rahman',
            subtitle: 'Misyari Rasyid Al-Afasi',
            progress: 0.58,
            onTap: () {},
            actions: [
              IconCircleButton(
                icon: AppIcons.heart,
                semanticLabel: 'Favoritkan',
                size: 32,
                iconSize: 16,
                iconColor: AppColors.textMuted,
                onTap: () {},
              ),
              IconCircleButton(
                icon: AppIcons.play,
                semanticLabel: 'Putar',
                style: IconCircleStyle.primary,
                size: 32,
                iconSize: 11,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        AppBottomNavBar(
          items: AppBottomNavBar.defaultItems,
          currentIndex: _nav,
          onChanged: (i) => setState(() => _nav = i),
        ),
      ],
    );
  }

  Widget _explore() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchField(
            hint: 'Cari surat, qari, juz, atau tafsir...',
            fillColor: AppColors.surfaceAt(0.6),
            borderColor: AppColors.borderAt(0.5),
            iconColor: AppColors.accent,
            height: 49,
            onMicTap: () {},
          ),
          const SizedBox(height: 28),
          const SectionHeader(
            title: 'Jelajah Kategori',
            accentBar: true,
            trailingLabel: null,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CategoryCard(
                  icon: AppIcons.tafsir,
                  title: 'Al-Qur\'an 30 Juz',
                  subtitle: '114 Surat • Audio HD',
                  cta: 'Dengarkan',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CategoryCard(
                  icon: AppIcons.qari,
                  title: 'Qari & Murottal',
                  subtitle: 'Misyari, Sudais, Juhany',
                  cta: 'Jelajahi Profil',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeader(
            title: 'Tafsir & Tadabbur Pilihan',
            subtitle: 'Kajian mendalam Kemenag RI & Ibnu Katsir',
            accentBar: true,
            trailingLabel: 'Lihat Semua 114 Surat',
          ),
          const SizedBox(height: 8),
          FilterChipBar(
            variant: FilterChipVariant.accent,
            padding: EdgeInsets.zero,
            items: const [
              FilterChipItem('Semua Tafsir'),
              FilterChipItem('Tafsir Kemenag'),
              FilterChipItem('Ringkasan Tahlili'),
            ],
            selectedIndex: _tafsirChip,
            onSelected: (i) => setState(() => _tafsirChip = i),
          ),
          const SizedBox(height: 8),
          TafsirCard(
            tag: 'Surah ke-1',
            meta: 'Makkiyyah • 7 Ayat',
            infoIcon: AppIcons.timer,
            infoLabel: '14 mnt audio',
            title: 'Surah Al-Fatihah',
            subtitle: 'Ummul Kitab & Intisari Al-Qur\'an',
            description:
                'Pondasi utama shalat yang merangkum ketauhidan, permohonan hidayah jalan yang lurus.',
            leftActionIcon: AppIcons.playCircle,
            leftActionLabel: 'Dengarkan Audio',
            rightActionLabel: 'Baca Tafsir Lengkap',
            onLeftAction: () {},
            onRightAction: () {},
          ),
          const SizedBox(height: 8),
          TafsirCard(
            tag: 'Ayat Agung',
            meta: 'QS. Al-Baqarah: 255',
            infoIcon: AppIcons.shield,
            infoLabel: 'Proteksi Diri',
            title: 'Ayat Kursi (Ayatul Kursi)',
            subtitle: 'Kemuliaan Tauhid & Kekuasaan Mutlak Ilahi',
            arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
            arabicTranslation:
                'Allah, tidak ada tuhan selain Dia. Yang Mahahidup, yang terus-menerus mengurus ciptaan-Nya...',
            description:
                'Menyajikan penegasan bahwa tiada kantuk dan tidur bagi-Nya, serta keluasan ilmu dan kekuasaan.',
            leftActionIcon: AppIcons.headphones,
            leftActionLabel: 'Kajian Makna',
            rightActionLabel: 'Buka Lembar Tafsir',
            onLeftAction: () {},
            onRightAction: () {},
          ),
          const SizedBox(height: 8),
          AyahQuoteCard(
            reference: 'QS. Ar-Rahman: 13',
            arabic: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
            translation: 'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
            caption: 'Dengarkan audio tafsir lengkap',
            actionLabel: 'Putar Tafsir',
            onAction: () {},
          ),
          const SizedBox(height: 16),
          MiniPlayer(
            leading: const MiniPlayerLeading.text('١'),
            title: 'Surat Ar-Rahman (Ayat 1–78)',
            subtitle: 'Misyari Rasyid Al-Afasi',
            progress: 0.2,
            actions: [
              IconCircleButton(
                icon: AppIcons.playCircle,
                semanticLabel: 'Putar',
                size: 40,
                iconSize: 24,
                iconColor: AppColors.accentLight,
                onTap: () {},
              ),
              IconCircleButton(
                icon: AppIcons.next,
                semanticLabel: 'Berikutnya',
                size: 32,
                iconSize: 14,
                iconColor: AppColors.skyLabel,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _player() {
    return SizedBox(
      height: 884,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Image(image: _starfield, fit: BoxFit.cover),
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
                  onTap: () {},
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
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: AyahLyricsView(
                    previousArabic: 'الرَّحْمَٰنُ (١) عَلَّمَ الْقُرْآنَ (٢)',
                    activeArabic: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
                    translation:
                        'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
                    nextArabic: 'خَلَقَ الْإِنسَانَ (٣) عَلَّمَهُ الْبَيَانَ (٤)',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
                          icon: AppIcons.heartFilled,
                          semanticLabel: 'Simpan ke favorit',
                          style: IconCircleStyle.glass,
                          size: 44,
                          iconSize: 20,
                          iconColor: AppColors.accentLight,
                          onTap: () {},
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
                      value: _seek,
                      buffered: 0.65,
                      onChanged: (v) => setState(() => _seek = v),
                    ),
                    const SizedBox(height: 4),
                    const PlayerTimeline(
                      elapsed: '04:15',
                      remaining: '-12:15',
                      centerLabel: 'Ayat 13 dari 78',
                    ),
                    const SizedBox(height: 16),
                    PlayerControls(
                      playing: true,
                      repeatOne: true,
                      onPlayPause: () {},
                    ),
                    const SizedBox(height: 24),
                    QariFooterCard(
                      image: _qariAfasi,
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

  Widget _library() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            selectedIndex: _chip,
            onSelected: (i) => setState(() => _chip = i),
          ),
          const SizedBox(height: 16),
          ActionRowCard(
            icon: AppIcons.playlistAdd,
            title: 'Buat Playlist Baru',
            subtitle: 'Kumpulkan tilawah, wirid & dzikir favoritmu',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Playlist Tersimpan',
            count: 4,
            titleStyle: AppTextStyles.heading.copyWith(fontSize: 16),
            trailingLabel: 'Lihat Semua',
          ),
          const SizedBox(height: 10),
          MediaRow(
            leading: const MediaThumb(image: _arRahman),
            title: 'Surat Favorit Rutin',
            favorite: true,
            subtitle: 'Dibuat oleh Aisyah • 12 Surat',
            tagline: 'Ar-Rahman, Al-Waqi\'ah, Al-Mulk',
            onMore: () {},
          ),
          const SizedBox(height: 10),
          MediaRow(
            leading: const MediaThumb(
              image: _masjid,
              overlayIcon: AppIcons.offlineDone,
            ),
            title: 'Dzikir Pagi & Petang',
            offline: true,
            subtitle: 'Al-Ma\'tsurat Lengkap • 8 Audio',
            tagline: 'Syaikh Sa\'ad Al-Ghamidi',
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
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Riwayat Tilawah Terakhir',
            trailingLabel: 'Lihat lebih banyak',
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
          const SectionHeader(
            title: 'Penanda Ayat Tersimpan',
            count: 12,
            trailingLabel: 'Lihat Semua',
          ),
          const SizedBox(height: 10),
          BookmarkCard(
            reference: 'QS. Ar-Rahman : 13',
            page: 'Halaman 531',
            arabic: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
            translation: 'Maka nikmat Tuhanmu yang manakah yang kamu',
            onListen: () {},
            onRemove: () {},
          ),
        ],
      ),
    );
  }

  Widget _reader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SurahHeaderCard(
            metadata: 'Surat ke-55 • 78 Ayat • Makkiyah',
            arabicName: 'الرَّحْمٰن',
            latinName: 'Ar-Rahman',
            meaning: '(Yang Maha Pengasih)',
            qariName: 'Misyari Rasyid',
          ),
          const SizedBox(height: 16),
          const BasmalahHeader(
            arabic: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
            translation: 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang',
          ),
          const SizedBox(height: 16),
          AyahTile(
            number: 1,
            arabic: 'الرَّحْمٰنُۙ',
            transliteration: 'Ar-raḥmān',
            translation: '(Allah) Yang Maha Pengasih.',
            onPlay: () {},
            onBookmark: () {},
          ),
          const SizedBox(height: 8),
          AyahTile(
            number: 4,
            active: true,
            playing: true,
            bookmarked: true,
            playbackLabel: 'Memutar 00:03',
            repeatLabel: 'Ulang 3x',
            arabic: 'عَلَّمَهُ الْبَيَانَ',
            transliteration: "'Allamahul-bayān",
            translation: 'Mengajarnya pandai berbicara.',
            onPlay: () {},
            onBookmark: () {},
            onTafsir: () {},
            onRepeat: () {},
          ),
          const SizedBox(height: 8),
          AyahTile(
            number: 5,
            arabic: 'اَلشَّمْسُ وَالْقَمَرُ بِحُسْبَانٍۙ',
            transliteration: 'Asy-syamsu wal-qamaru biḥusbān',
            translation: 'Matahari dan bulan beredar menurut perhitungan.',
            onPlay: () {},
            onBookmark: () {},
          ),
          const SizedBox(height: 16),
          const Center(child: SyncStatusPill()),
          const SizedBox(height: 8),
          MiniPlayer(
            leading: const MiniPlayerLeading.text('٠٠:٤'),
            title: 'Ar-Rahman : Ayat 4',
            subtitle: 'Misyari Rasyid Al-Afasi',
            progress: 0.3,
            actions: [
              IconCircleButton(
                icon: AppIcons.previous,
                semanticLabel: 'Ayat sebelumnya',
                size: 32,
                iconSize: 12,
                iconColor: AppColors.textMuted,
                onTap: () {},
              ),
              IconCircleButton(
                icon: AppIcons.pause,
                semanticLabel: 'Jeda',
                style: IconCircleStyle.primary,
                size: 40,
                iconSize: 14,
                onTap: () {},
              ),
              IconCircleButton(
                icon: AppIcons.next,
                semanticLabel: 'Ayat berikutnya',
                size: 32,
                iconSize: 12,
                iconColor: AppColors.textMuted,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          PillButton(label: 'Tafsir', leadingIcon: AppIcons.tafsir),
          PillButton(label: 'Ulang 3x', leadingIcon: AppIcons.repeat),
          IconCircleButton(
            icon: AppIcons.add,
            semanticLabel: 'Tambah',
            style: IconCircleStyle.tonal,
            iconColor: AppColors.accentLight,
          ),
          IconCircleButton(
            icon: AppIcons.sort,
            semanticLabel: 'Urutkan',
            style: IconCircleStyle.outlined,
            iconColor: AppColors.skyLabel,
          ),
        ],
      ),
    );
  }

  Widget _pickers() {
    const qaris = [
      QariOption(
        id: '05',
        name: 'Misyari Rasyid Al-Afasi',
        origin: 'Kuwait · Murattal',
      ),
      QariOption(
        id: '01',
        name: 'Abdurrahman As-Sudais',
        origin: 'Arab Saudi · Murattal',
      ),
      QariOption(
        id: '02',
        name: 'Saad Al-Ghamdi',
        origin: 'Arab Saudi · Murattal',
      ),
    ];
    const surahs = [
      SurahOption(number: 1, name: 'Al-Fatihah', ayahCount: 7),
      SurahOption(number: 2, name: 'Al-Baqarah', ayahCount: 286),
      SurahOption(number: 18, name: 'Al-Kahf', ayahCount: 110),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlaybackSelectorCard(
            qariName: 'Misyari Rasyid Al-Afasi',
            surahName: 'Al-Fatihah',
            ayahNumber: 1,
            onQariTap: () => showQariPicker(
              context,
              options: qaris,
              selected: qaris.first,
            ),
            onSurahTap: () => showSurahPicker(
              context,
              options: surahs,
              selected: surahs.first,
            ),
            onAyahTap: () => showAyahPicker(
              context,
              surahName: 'Al-Fatihah',
              ayahCount: 7,
              current: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: SelectorField(label: 'Pilih Surat', value: 'Al-Fatihah'),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 106,
                child: SelectorField(label: 'Ayat', value: '1'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NumberStepper(
            value: _stepper,
            min: 1,
            max: 78,
            onChanged: (v) => setState(() => _stepper = v),
          ),
          const SizedBox(height: 16),
          const AppButton(label: 'Ayat pertama'),
          const SizedBox(height: 8),
          const AppButton(
            label: 'Selesai',
            style: AppButtonStyle.primary,
            height: 50,
          ),
        ],
      ),
    );
  }
}
