import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/media_card.dart';
import '../../../shared/widgets/quote_banner.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/shelf.dart';
import '../../player/application/player_providers.dart';
import '../../player/domain/media_item.dart';

/// Beranda: sapaan, qari favorit, rekomendasi, kurasi, dan kutipan ayat.
///
/// Data di file ini adalah contoh dari Figma dan akan diganti oleh repositori
/// (docs/02 §3) saat lapisan data dibuat.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _aisyah = AssetImage('assets/images/avatars/aisyah.png');

  static const _favoriteQaris = [
    (
      id: '05',
      name: 'Al-Afasi',
      image: AssetImage('assets/images/qari/misyari-rasyid-al-afasi.webp'),
    ),
    (
      id: '03',
      name: 'As-Sudais',
      image: AssetImage('assets/images/qari/abdurrahman-as-sudais.webp'),
    ),
    (
      id: '01',
      name: 'Al-Juhany',
      image: AssetImage('assets/images/qari/abdullah-al-juhany.webp'),
    ),
    (
      id: '04',
      name: 'Al-Dosari',
      image: AssetImage('assets/images/qari/ibrahim-al-dossari.webp'),
    ),
    (
      id: '02',
      name: 'Al-Qasim',
      image: AssetImage('assets/images/qari/abdul-muhsin-al-qasim.webp'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    void openReader() => Navigator.of(context).pushNamed(AppRoutes.reader);

    return Column(
      children: [
        AppTopBar(
          leading: const AvatarRing(
            image: _aisyah,
            onlineDot: true,
            semanticLabel: 'Foto profil Aisyah',
          ),
          center: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: 'Qari Favorit',
                  onChevronTap: () {},
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _favoriteQaris.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        QariAvatarItem(
                          image: _favoriteQaris[i].image,
                          name: _favoriteQaris[i].name,
                          selected:
                              player.selectedQariId == _favoriteQaris[i].id,
                          onTap: () => unawaited(
                            player.selectQari(_favoriteQaris[i].id),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Shelf(
                  title: 'Rekomendasi Tilawah & Surat Terkini',
                  onSeeAll: () {},
                  children: [
                    MediaCard(
                      image: const AssetImage('assets/images/covers/ar-rahman.png'),
                      arabicTitle: 'الرحمن',
                      title: 'Surat Ar-Rahman',
                      subtitle: 'Misyari Rasyid Al-Afasi',
                      onTap: openReader,
                    ),
                    MediaCard(
                      image: const AssetImage('assets/images/covers/al-kahfi.png'),
                      arabicTitle: 'الكهف',
                      pillLabel: 'Jumat',
                      title: 'Surat Al-Kahfi',
                      subtitle: 'Abdurrahman As-Sudais',
                      onTap: () => PlayerScope.read(context).playSurah(18, qariId: '03'),
                    ),
                    MediaCard(
                      image: const AssetImage('assets/images/covers/yasin.png'),
                      arabicTitle: 'يس',
                      title: 'Surat Yasin',
                      subtitle: 'Abdullah Al-Juhany',
                      onTap: () => PlayerScope.read(context).playSurah(36, qariId: '01'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Shelf(
                  title: 'Dibuat Untuk Kamu',
                  onSeeAll: () {},
                  children: [
                    const MediaCard(
                      image: AssetImage('assets/images/covers/mix-harian.png'),
                      badgeIcon: AppIcons.sparkle,
                      overlayLabel: 'MIX HARIAN',
                      title: 'Daily Murattal Mix 1',
                      subtitle: 'Al-Afasi, As-Sudais, Al-Juhany',
                    ),
                    MediaCard(
                      image: const AssetImage('assets/images/covers/dzikir-petang.png'),
                      badgeIcon: AppIcons.adhkar,
                      overlayLabel: 'VOCAL-ONLY',
                      overlayLabelColor: AppColors.skyLabel,
                      title: 'Dzikir Penenang Petang',
                      subtitle: 'Vocal-only, tanpa musik',
                      onTap: () => PlayerScope.read(context).playItem(
                        MediaItem(
                          id: 'adhkar:a-petang',
                          kind: MediaKind.adhkar,
                          source: MediaSource.mock,
                          title: 'Dzikir Penenang Petang',
                          subtitle: 'Vocal-only · Contoh Audio',
                          duration: const Duration(minutes: 3, seconds: 15),
                          audioUri: Uri.parse('asset://assets/audio_samples/sample_01.mp3'),
                          artwork: 'assets/images/covers/dzikir-petang.png',
                        ),
                        queueSource: 'Dibuat Untuk Kamu',
                      ),
                    ),
                    const MediaCard(
                      image: AssetImage('assets/images/covers/yasin.png'),
                      badgeIcon: AppIcons.tafsir,
                      overlayLabel: 'KAJIAN SINGKAT',
                      title: 'Tadabbur Juz Amma',
                      subtitle: 'Renungan Ayat-Ayat Pendek',
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: QuoteBanner(
                    quote:
                        'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
                    reference: "QS. Ar-Ra'd : 28",
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
