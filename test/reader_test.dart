import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app_final_project/features/player/application/player_controller.dart';
import 'package:quran_app_final_project/features/player/data/audio_engine.dart';
import 'package:quran_app_final_project/features/player/domain/media_item.dart';
import 'package:quran_app_final_project/features/player/domain/player_state.dart';
import 'package:quran_app_final_project/features/quran/application/quran_providers.dart';
import 'package:quran_app_final_project/features/quran/domain/ayah.dart';
import 'package:quran_app_final_project/features/quran/domain/quran_repository.dart';
import 'package:quran_app_final_project/features/quran/domain/surah.dart';
import 'package:quran_app_final_project/features/quran/domain/tafsir.dart';
import 'package:quran_app_final_project/features/reader/application/reader_controller.dart';
import 'package:quran_app_final_project/features/reader/application/sync_engine.dart';
import 'package:quran_app_final_project/features/reader/domain/reader_settings.dart';
import 'package:quran_app_final_project/features/reader/presentation/basmalah_header.dart';
import 'package:quran_app_final_project/features/reader/presentation/reader_screen.dart';

class _FakeReaderQuranRepository implements QuranRepository {
  static final _fatihah = Surah(
    number: 1,
    arabicName: 'الفاتحة',
    latinName: 'Al-Fatihah',
    meaning: 'Pembukaan',
    revelation: Revelation.makkiyah,
    ayahCount: 7,
    descriptionPlain: 'Pembukaan',
    fullAudio: {
      '05': Uri.parse('https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/001.mp3'),
    },
    ayat: [
      Ayah(
        surahNumber: 1,
        number: 1,
        arabic: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
        transliteration: 'Bismillāhir-raḥmānir-raḥīm(i).',
        translation: 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
        audio: {
          '05': Uri.parse('https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/001001.mp3'),
        },
      ),
    ],
  );

  static final _baqarah = Surah(
    number: 2,
    arabicName: 'البقرة',
    latinName: 'Al-Baqarah',
    meaning: 'Sapi Betina',
    revelation: Revelation.madaniyah,
    ayahCount: 286,
    descriptionPlain: 'Al-Baqarah',
    fullAudio: {
      '05': Uri.parse('https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/002.mp3'),
    },
    ayat: [
      Ayah(
        surahNumber: 2,
        number: 1,
        arabic: 'الۤمّۤ ۚ',
        transliteration: 'Alif lām mīm.',
        translation: 'Alif Lam Mim.',
        audio: const {},
      ),
      Ayah(
        surahNumber: 2,
        number: 282,
        arabic: 'يٰٓاَيُّهَا الَّذِيْنَ اٰمَنُوْٓا اِذَا تَدَايَنْتُمْ بِدَيْنٍ اِلٰٓى اَجَلٍ مُّسَمًّى فَاكْتُبُوْهُۗ',
        transliteration: 'Yā ayyuhal-lażīna āmanū...',
        translation: 'Wahai orang-orang yang beriman! Apabila kamu melakukan utang piutang...',
        audio: const {},
      ),
    ],
  );

  static final _taubah = Surah(
    number: 9,
    arabicName: 'التوبة',
    latinName: 'At-Taubah',
    meaning: 'Pengampunan',
    revelation: Revelation.madaniyah,
    ayahCount: 129,
    descriptionPlain: 'At-Taubah',
    fullAudio: const {},
    ayat: [
      Ayah(
        surahNumber: 9,
        number: 1,
        arabic: 'بَرَاۤءَةٌ مِّنَ اللّٰهِ وَرَسُوْلِهٖٓ',
        transliteration: 'Barā\'atum minallāhi wa rasūlih(ī)',
        translation: '(Inilah pernyataan) pemutusan hubungan dari Allah dan Rasul-Nya',
        audio: const {},
      ),
    ],
  );

  static final _nas = Surah(
    number: 114,
    arabicName: 'الناس',
    latinName: 'An-Nas',
    meaning: 'Manusia',
    revelation: Revelation.makkiyah,
    ayahCount: 6,
    descriptionPlain: 'An-Nas',
    fullAudio: const {},
    ayat: [
      Ayah(
        surahNumber: 114,
        number: 1,
        arabic: 'قُلْ اَعُوْذُ بِرَبِّ النَّاسِۙ',
        transliteration: 'Qul a‘ūżu birabbin-nās(i).',
        translation: 'Katakanlah, "Aku berlindung kepada Tuhannya manusia,',
        audio: const {},
      ),
    ],
  );

  @override
  Future<List<Surah>> getSurahs({bool forceRefresh = false}) async =>
      [_fatihah, _baqarah, _taubah, _nas];

  @override
  Future<Surah> getSurahDetail(int number, {bool forceRefresh = false}) async {
    switch (number) {
      case 1:
        return _fatihah;
      case 2:
        return _baqarah;
      case 9:
        return _taubah;
      case 114:
        return _nas;
      default:
        return _fatihah;
    }
  }

  @override
  Future<SurahTafsir> getTafsir(int number, {bool forceRefresh = false}) async {
    return SurahTafsir(
      surahNumber: number,
      entries: const [
        TafsirEntry(startAyah: 1, endAyah: 1, text: 'Tafsir ayat pertama.'),
      ],
    );
  }
}

Widget _wrapReader(
  ReaderController reader,
  PlayerController player,
  int surahNumber,
) {
  return PlayerScope(
    controller: player,
    child: ReaderScope(
      controller: reader,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: ReaderScreen(surahNumber: surahNumber),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Uji teks suci & Basmalah (docs/06 §1, §6)', () {
    testWidgets('teks Arab dan terjemahan identik dengan data API untuk Al-Fatihah, Al-Baqarah, An-Nas', (tester) async {
      final repo = _FakeReaderQuranRepository();
      final reader = ReaderController(repository: repo);
      final player = PlayerController(
        engine: SimulatedAudioEngine(),
        quranRepository: repo,
      );
      addTearDown(() {
        reader.dispose();
        player.dispose();
      });

      // Surat 1 (Al-Fatihah): tidak ada kepala Basmalah terpisah.
      await tester.pumpWidget(_wrapReader(reader, player, 1));
      await tester.pumpAndSettle();
      expect(find.byType(BasmalahHeader), findsNothing);
      expect(find.text('بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ'), findsOneWidget);

      // Surat 2 (Al-Baqarah): kepala Basmalah tampil, ayat 1 & 282 identik.
      await reader.loadSurah(2);
      await tester.pumpWidget(_wrapReader(reader, player, 2));
      await tester.pumpAndSettle();
      expect(find.byType(BasmalahHeader), findsOneWidget);
      expect(find.text('الۤمّۤ ۚ'), findsOneWidget);
      expect(find.text('Alif Lam Mim.'), findsOneWidget);

      // Surat 9 (At-Taubah): tanpa kepala Basmalah.
      await reader.loadSurah(9);
      await tester.pumpWidget(_wrapReader(reader, player, 9));
      await tester.pumpAndSettle();
      expect(find.byType(BasmalahHeader), findsNothing);
      expect(find.text('بَرَاۤءَةٌ مِّنَ اللّٰهِ وَرَسُوْلِهٖٓ'), findsOneWidget);

      // Surat 114 (An-Nas): kepala Basmalah tampil, teks Arab identik.
      await reader.loadSurah(114);
      await tester.pumpWidget(_wrapReader(reader, player, 114));
      await tester.pumpAndSettle();
      expect(find.byType(BasmalahHeader), findsOneWidget);
      expect(find.text('قُلْ اَعُوْذُ بِرَبِّ النَّاسِۙ'), findsOneWidget);
    });
  });

  group('SyncEngine Mode A & B', () {
    const engine = SyncEngine();
    final surah = _FakeReaderQuranRepository._baqarah;

    test('Mode B menghitung mulai menaik dan menjepit posisi di luar rentang', () {
      const dur = Duration(seconds: 120);
      final starts = engine.computeAyahStartTimes(
        surah.ayat,
        dur,
        includeBasmalahHeader: true,
      );
      expect(starts.length, 2);
      expect(starts[0] > Duration.zero, isTrue);
      expect(starts[1] > starts[0], isTrue);

      final item = MediaItem(
        id: 'surah:2:05',
        kind: MediaKind.surah,
        source: MediaSource.api,
        title: 'Surat Al-Baqarah',
        subtitle: 'Misyari',
        duration: dur,
        audioUri: Uri.parse('https://cdn.equran.id/002.mp3'),
        meta: const {'surahNumber': 2},
      );

      final atZero = engine.resolve(
        surah: surah,
        current: item,
        pos: const PlaybackPosition(position: Duration.zero, duration: dur),
      );
      expect(atZero.activeAyah, 1);
      expect(atZero.isEstimated, isTrue);

      final atEnd = engine.resolve(
        surah: surah,
        current: item,
        pos: const PlaybackPosition(position: Duration(seconds: 999), duration: dur),
      );
      expect(atEnd.activeAyah, 282);
    });

    test('Mode A mengambil nomor ayat langsung dari item aktif', () {
      final ayahItem = MediaItem(
        id: 'ayah:2:282:05',
        kind: MediaKind.ayah,
        source: MediaSource.api,
        title: 'Al-Baqarah : 282',
        subtitle: 'Misyari',
        audioUri: Uri.parse('https://cdn.equran.id/002282.mp3'),
        meta: const {'surahNumber': 2, 'ayahNumber': 282},
      );

      final res = engine.resolve(
        surah: surah,
        current: ayahItem,
        pos: const PlaybackPosition(),
      );
      expect(res.activeAyah, 282);
      expect(res.isEstimated, isFalse);
    });
  });

  group('Tafsir parser & ReaderController', () {
    test('TafsirEntry menangani ayat string, rentang, dan entri tak valid tanpa crash', () {
      final tafsir = SurahTafsir.fromJson({
        'nomor': 1,
        'tafsir': [
          {'ayat': '1', 'teks': 'Pertama'},
          {'ayat': '2-3', 'teks': 'Kedua dan ketiga'},
          {'ayat': 'invalid', 'teks': 'Diabaikan'},
        ],
      });
      expect(tafsir.forAyah(1)?.text, 'Pertama');
      expect(tafsir.forAyah(2)?.text, 'Kedua dan ketiga');
      expect(tafsir.forAyah(3)?.text, 'Kedua dan ketiga');
      expect(tafsir.forAyah(4), isNull);
    });

    test('toggleBookmark dan updateSettings memperbarui state ReaderController', () async {
      final reader = ReaderController(repository: _FakeReaderQuranRepository());
      addTearDown(reader.dispose);
      final surah = _FakeReaderQuranRepository._nas;
      final ayah = surah.ayat.first;

      await reader.toggleBookmark(surah, ayah);
      expect(reader.isBookmarked(114, 1), isTrue);
      await reader.toggleBookmark(surah, ayah);
      expect(reader.isBookmarked(114, 1), isFalse);

      await reader.updateSettings(
        reader.settings.copyWith(
          mode: ReaderMode.mushaf,
          arabicSizeLevel: 5,
        ),
      );
      expect(reader.settings.mode, ReaderMode.mushaf);
      expect(reader.settings.arabicFontSize, 40.0);
    });
  });
}
