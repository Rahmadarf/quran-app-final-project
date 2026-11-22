import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../player/application/player_controller.dart';
import '../../player/presentation/mini_player.dart';
import 'ayah_tile.dart';
import 'basmalah_header.dart';
import 'surah_header_card.dart';
import 'sync_status_pill.dart';

/// Reader surat dengan sorotan ayat yang mengikuti pemutar.
///
/// PENTING: teks Arab, transliterasi, dan terjemahan di bawah hanyalah contoh
/// dari Figma untuk 5 ayat pertama Ar-Rahman. Pada implementasi nyata teks
/// harus datang dari API equran.id dan ditampilkan tanpa diubah (docs/06 §6).
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _Ayah {
  const _Ayah(this.arabic, this.transliteration, this.translation);

  final String arabic;
  final String transliteration;
  final String translation;
}

class _ReaderScreenState extends State<ReaderScreen> {
  static const _ayat = [
    _Ayah('الرَّحْمٰنُۙ', 'Ar-raḥmān', '(Allah) Yang Maha Pengasih.'),
    _Ayah('عَلَّمَ الْقُرْاٰنَۗ', "'allamal-qur'ān", 'Yang telah mengajarkan Al-Qur\'an.'),
    _Ayah('خَلَقَ الْاِنْسَانَۙ', 'Khalaqal-insān', 'Dia menciptakan manusia.'),
    _Ayah('عَلَّمَهُ الْبَيَانَ', "'Allamahul-bayān", 'Mengajarnya pandai berbicara.'),
    _Ayah(
      'اَلشَّمْسُ وَالْقَمَرُ بِحُسْبَانٍۙ',
      'Asy-syamsu wal-qamaru biḥusbān',
      'Matahari dan bulan beredar menurut perhitungan.',
    ),
  ];

  /// Indeks ayat yang sedang disorot (0-based). Ayat ke-4 seperti di Figma.
  int _active = 3;
  final Set<int> _bookmarked = {3};
  bool _transliteration = true;

  void _playAyah(int index, PlayerController player) {
    if (_active == index) {
      player.togglePlay();
    } else {
      setState(() => _active = index);
      player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);

    return ColoredBox(
      color: AppColors.background,
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
                  'Surah Ar-Rahman',
                  style: AppTextStyles.custom(
                    size: 18,
                    lineHeight: 24,
                    weight: FontWeight.w600,
                    color: AppColors.textPlayerTitle,
                    letterSpacing: -0.45,
                  ),
                ),
                Text(
                  'Surat ke-55 • 78 Ayat',
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
                  icon: AppIcons.share,
                  semanticLabel: 'Bagikan surat',
                  size: 40,
                  iconSize: 17,
                  iconColor: AppColors.textMuted,
                  onTap: () {},
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SurahHeaderCard(
                    metadata: 'Surat ke-55 • 78 Ayat • Makkiyah',
                    arabicName: 'الرَّحْمٰن',
                    latinName: 'Ar-Rahman',
                    meaning: '(Yang Maha Pengasih)',
                    qariName: 'Misyari Rasyid',
                    transliterationOn: _transliteration,
                    repeatOn: player.repeatOne,
                    onTransliterationTap: () =>
                        setState(() => _transliteration = !_transliteration),
                    onRepeatTap: player.toggleRepeatOne,
                  ),
                  const SizedBox(height: 16),
                  const BasmalahHeader(
                    arabic: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                    translation:
                        'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang',
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < _ayat.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _tile(i, player),
                  ],
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SyncStatusPill(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              8,
              0,
              8,
              8 + MediaQuery.paddingOf(context).bottom,
            ),
            child: _miniPlayer(player),
          ),
        ],
      ),
    );
  }

  Widget _tile(int i, PlayerController player) {
    final active = i == _active;
    final a = _ayat[i];
    return AyahTile(
      number: i + 1,
      arabic: a.arabic,
      transliteration: _transliteration ? a.transliteration : null,
      translation: a.translation,
      active: active,
      playing: active && player.playing,
      bookmarked: _bookmarked.contains(i),
      playbackLabel: active ? 'Memutar ${formatClock(player.elapsedSeconds % 60)}' : null,
      repeatLabel: active ? 'Ulang 3x' : null,
      onPlay: () => _playAyah(i, player),
      onBookmark: () => setState(() {
        if (!_bookmarked.remove(i)) _bookmarked.add(i);
      }),
      onTafsir: () {},
      onRepeat: () {},
    );
  }

  Widget _miniPlayer(PlayerController player) {
    return MiniPlayer(
      leading: MiniPlayerLeading.text(_arabicDigits(_active + 1)),
      title: 'Ar-Rahman : Ayat ${_active + 1}',
      subtitle: 'Misyari Rasyid Al-Afasi',
      progress: (_active + 1) / _ayat.length,
      onTap: () => Navigator.of(context).pushNamed('/player'),
      actions: [
        IconCircleButton(
          icon: AppIcons.previous,
          semanticLabel: 'Ayat sebelumnya',
          size: 32,
          iconSize: 12,
          iconColor: AppColors.textMuted,
          onTap: _active > 0 ? () => setState(() => _active--) : null,
        ),
        IconCircleButton(
          icon: player.playing ? AppIcons.pause : AppIcons.play,
          semanticLabel: player.playing ? 'Jeda' : 'Putar',
          style: IconCircleStyle.primary,
          size: 40,
          iconSize: 14,
          onTap: player.togglePlay,
        ),
        IconCircleButton(
          icon: AppIcons.next,
          semanticLabel: 'Ayat berikutnya',
          size: 32,
          iconSize: 12,
          iconColor: AppColors.textMuted,
          onTap: _active < _ayat.length - 1
              ? () => setState(() => _active++)
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
