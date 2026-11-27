import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/filter_chip_bar.dart';
import '../../../shared/widgets/section_header.dart';
import 'tafsir_card.dart';

/// Jelajah dual-mode sesuai Figma `04 — Jelajah (Explore)`.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _filter = 0;

  static const _categories = [
    (AppIcons.qari, 'Qari & Murottal', '6 Qari · Audio HD', 'Jelajahi'),
    (AppIcons.adhkar, 'Adhkar & Doa', 'Pagi, Petang · Vocal-only', 'Mulai'),
    (AppIcons.tafsir, 'Tafsir Kemenag', '114 Surat · Makna Ayat', 'Baca'),
    (AppIcons.podcast, 'Kajian & Podcast', 'Tadabbur Harian', 'Dengar'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
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
                  'Jelajah',
                  style: AppTextStyles.display
                      .copyWith(color: palette.textPrimary),
                ),
                Text(
                  'Qari, Adhkar, Tafsir & Kajian Vocal-Only',
                  style:
                      AppTextStyles.caption.copyWith(color: palette.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppSearchField(
                    hint: 'Cari qari, adhkar, nasheed, atau tafsir…',
                  ),
                  const Gap(18),
                  for (var row = 0; row < _categories.length; row += 2) ...[
                    if (row > 0) const Gap(10),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = row; i < row + 2; i++) ...[
                            if (i > row) const Gap(10),
                            Expanded(
                              child: CategoryCard(
                                icon: _categories[i].$1,
                                title: _categories[i].$2,
                                subtitle: _categories[i].$3,
                                cta: _categories[i].$4,
                                onTap: openCollection,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const Gap(24),
                  SectionHeader(
                    title: 'Tafsir & Tadabbur',
                    trailingLabel: 'Lihat semua',
                    onTrailingTap: openCollection,
                  ),
                  const Gap(10),
                  FilterChipBar(
                    padding: EdgeInsets.zero,
                    items: const [
                      FilterChipItem('Semua'),
                      FilterChipItem('Kemenag RI'),
                      FilterChipItem('Asbabun Nuzul'),
                    ],
                    selectedIndex: _filter,
                    onSelected: (i) => setState(() => _filter = i),
                  ),
                  const Gap(6),
                  TafsirCard(
                    tag: 'Ayat Agung',
                    meta: 'QS. Al-Baqarah : 255',
                    infoIcon: AppIcons.shield,
                    infoLabel: 'Proteksi Diri',
                    title: 'Ayat Kursi — Kemuliaan Tauhid',
                    subtitle: 'Kemuliaan Tauhid & Kekuasaan Mutlak Ilahi',
                    arabic:
                        'اللّٰهُ لَآ اِلٰهَ اِلَّا هُوَۚ اَلْحَيُّ الْقَيُّوْمُ',
                    description:
                        'Penegasan keesaan Allah Yang Mahahidup dan terus-menerus mengurus makhluk-Nya.',
                    leftActionIcon: AppIcons.headphones,
                    leftActionLabel: 'Dengarkan',
                    rightActionLabel: 'Buka Reader',
                    onLeftAction: () => openReader(2, ayah: 255),
                    onRightAction: () => openReader(2, ayah: 255),
                    onTap: () => openReader(2, ayah: 255),
                  ),
                  TafsirCard(
                    tag: 'Surah ke-1',
                    meta: 'QS. Al-Fatihah : 1–7',
                    infoIcon: AppIcons.timer,
                    infoLabel: 'Makkiyah · 7 Ayat',
                    title: "Ummul Kitab & Intisari Al-Qur'an",
                    subtitle: 'Pondasi utama shalat dan doa hidayah',
                    arabic: 'اِيَّاكَ نَعْبُدُ وَاِيَّاكَ نَسْتَعِيْنُۗ',
                    description:
                        'Pondasi utama shalat yang merangkum pujian, penghambaan, dan doa hidayah jalan lurus.',
                    leftActionIcon: AppIcons.playCircle,
                    leftActionLabel: 'Dengarkan',
                    rightActionLabel: 'Buka Reader',
                    onLeftAction: () => openReader(1),
                    onRightAction: () => openReader(1),
                    onTap: () => openReader(1),
                  ),
                  const Gap(16),
                  AyahQuoteCard(
                    reference: 'QS. Ar-Rahman : 13',
                    arabic: 'فَبِاَيِّ اٰلَاۤءِ رَبِّكُمَا تُكَذِّبٰنِ',
                    translation:
                        'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?',
                    caption: 'Dengarkan & baca tafsir ayat',
                    actionLabel: 'Buka Ayat',
                    onAction: () => openReader(55, ayah: 13),
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
