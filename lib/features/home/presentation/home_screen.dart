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

/// Beranda: sapaan, qari favorit, rekomendasi, kurasi, dan kutipan ayat.
///
/// Data di file ini adalah contoh dari Figma dan akan diganti oleh repositori
/// (docs/02 §3) saat lapisan data dibuat.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _aisyah = AssetImage('assets/images/avatars/aisyah.png');

  @override
  Widget build(BuildContext context) {
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
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QariAvatarItem(
                        image: AssetImage('assets/images/qari/al-afasi-bisht.png'),
                        name: 'Al-Afasi',
                        selected: true,
                        alignment: Alignment(0, -0.7),
                      ),
                      SizedBox(width: 16),
                      QariAvatarItem(
                        image: AssetImage('assets/images/qari/as-sudais.png'),
                        name: 'As-Sudais',
                        alignment: Alignment(-0.2, 0),
                      ),
                      SizedBox(width: 16),
                      QariAvatarItem(
                        image: AssetImage('assets/images/qari/al-juhany.png'),
                        name: 'Al-Juhany',
                        alignment: Alignment(0.3, 0),
                      ),
                      SizedBox(width: 16),
                      QariAvatarItem(
                        image: AssetImage('assets/images/qari/al-dosari.png'),
                        name: 'Al-Dosari',
                      ),
                      SizedBox(width: 16),
                      QariAvatarItem(
                        image: AssetImage('assets/images/covers/ar-rahman.png'),
                        name: 'Al-Qasim',
                      ),
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
                    const MediaCard(
                      image: AssetImage('assets/images/covers/al-kahfi.png'),
                      arabicTitle: 'الكهف',
                      pillLabel: 'Jumat',
                      title: 'Surat Al-Kahfi',
                      subtitle: 'Abdurrahman As-Sudais',
                    ),
                    const MediaCard(
                      image: AssetImage('assets/images/covers/yasin.png'),
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
                      image: AssetImage('assets/images/covers/mix-harian.png'),
                      badgeIcon: AppIcons.sparkle,
                      overlayLabel: 'MIX HARIAN',
                      title: 'Daily Murattal Mix 1',
                      subtitle: 'Al-Afasi, As-Sudais, Al-Juhany',
                    ),
                    MediaCard(
                      image: AssetImage('assets/images/covers/dzikir-petang.png'),
                      badgeIcon: AppIcons.adhkar,
                      overlayLabel: 'VOCAL-ONLY',
                      overlayLabelColor: AppColors.skyLabel,
                      title: 'Dzikir Penenang Petang',
                      subtitle: 'Vocal-only, tanpa musik',
                    ),
                    MediaCard(
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
