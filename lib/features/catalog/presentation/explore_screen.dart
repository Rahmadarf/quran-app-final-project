import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/filter_chip_bar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/section_header.dart';
import 'tafsir_card.dart';

/// Jelajah: pencarian, kategori konten, dan tafsir/tadabbur pilihan.
///
/// Data di file ini adalah contoh dari Figma.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _filter = 0;

  static const _categories = [
    (AppIcons.quran, "Al-Qur'an 30 Juz", '114 Surat • Audio HD', 'Dengarkan'),
    (AppIcons.qari, 'Qari & Murottal', 'Misyari, Sudais, Juhany', 'Jelajahi Profil'),
    (AppIcons.adhkar, 'Adhkar & Doa', 'Pagi, Petang,…', 'Mulai Wirid'),
    (AppIcons.tafsir, "Tafsir Al-Qur'an", '114 Surat • Kajian Makna', 'Buka Tafsir'),
    (AppIcons.scroll, 'Asbabun Nuzul', 'Latar Belakang & Kisah', 'Pelajari'),
    (AppIcons.leaf, 'Koleksi Tematik', 'Penenang Jiwa & Ruqyah', 'Pilih Tema'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
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
              Text('Jelajah Kategori', style: AppTextStyles.heading),
              Text(
                "Audio Qur'an & Murottal",
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.accentLight,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          trailing: IconCircleButton(
            icon: AppIcons.search,
            semanticLabel: 'Cari',
            iconColor: AppColors.accentLight,
            iconSize: 17,
            onTap: () {},
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                  trailingNote: '6 Kategori',
                ),
                const SizedBox(height: 12),
                for (var row = 0; row < _categories.length; row += 2) ...[
                  if (row > 0) const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = row; i < row + 2; i++) ...[
                          if (i > row) const SizedBox(width: 8),
                          Expanded(child: _card(_categories[i])),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SectionHeader(
                  title: 'Tafsir & Tadabbur Pilihan',
                  subtitle: 'Kajian mendalam Kemenag RI & Ibnu Katsir',
                  accentBar: true,
                  trailingLabel: 'Lihat Semua 114 Surat',
                  onTrailingTap: () {},
                ),
                const SizedBox(height: 8),
                FilterChipBar(
                  variant: FilterChipVariant.accent,
                  padding: EdgeInsets.zero,
                  items: const [
                    FilterChipItem('Semua Tafsir'),
                    FilterChipItem('Tafsir Kemenag'),
                    FilterChipItem('Ringkasan Tahlili'),
                    FilterChipItem('Asbabun Nuzul'),
                  ],
                  selectedIndex: _filter,
                  onSelected: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: 8),
                TafsirCard(
                  tag: 'Surah ke-1',
                  meta: 'Makkiyyah • 7 Ayat',
                  infoIcon: AppIcons.timer,
                  infoLabel: '14 mnt audio',
                  title: 'Surah Al-Fatihah',
                  subtitle: "Ummul Kitab & Intisari Al-Qur'an",
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
                  translation:
                      'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
                  caption: 'Dengarkan audio tafsir lengkap',
                  actionLabel: 'Putar Tafsir',
                  onAction: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _card((AppIcons, String, String, String) c) => CategoryCard(
        icon: c.$1,
        title: c.$2,
        subtitle: c.$3,
        cta: c.$4,
        onTap: () {},
      );
}
