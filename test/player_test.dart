import 'package:flutter/widgets.dart' hide RepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app_final_project/core/errors/app_failure.dart';
import 'package:quran_app_final_project/core/utils/duration_format.dart';
import 'package:quran_app_final_project/features/player/application/player_controller.dart';
import 'package:quran_app_final_project/features/player/data/audio_engine.dart';
import 'package:quran_app_final_project/features/player/domain/media_item.dart';
import 'package:quran_app_final_project/features/player/domain/play_queue.dart';
import 'package:quran_app_final_project/features/player/domain/player_state.dart';
import 'package:quran_app_final_project/features/player/presentation/fullscreen_player.dart';
import 'package:quran_app_final_project/features/quran/application/quran_providers.dart';
import 'package:quran_app_final_project/features/quran/data/surah_dto.dart';
import 'package:quran_app_final_project/features/quran/domain/ayah.dart';
import 'package:quran_app_final_project/features/quran/domain/quran_repository.dart';
import 'package:quran_app_final_project/features/quran/domain/surah.dart';
import 'package:quran_app_final_project/features/quran/domain/tafsir.dart';
import 'package:quran_app_final_project/features/reader/application/reader_controller.dart';
import 'package:quran_app_final_project/features/reader/application/sync_engine.dart';

class _FakeQuranRepository implements QuranRepository {
  _FakeQuranRepository({this.shouldFail = false});

  final bool shouldFail;

  static final _surah55 = Surah(
    number: 55,
    arabicName: 'الرحمن',
    latinName: 'Ar-Rahman',
    meaning: 'Yang Maha Pengasih',
    revelation: Revelation.madaniyah,
    ayahCount: 78,
    descriptionPlain: 'Surat Ar-Rahman',
    fullAudio: {
      '05': Uri.parse('https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/055.mp3'),
    },
  );

  static final _surah112 = Surah(
    number: 112,
    arabicName: 'الإخلاص',
    latinName: 'Al-Ikhlas',
    meaning: 'Memurnikan Keesaan Allah',
    revelation: Revelation.makkiyah,
    ayahCount: 4,
    descriptionPlain: 'Surat Al-Ikhlas',
    fullAudio: {
      '05': Uri.parse('https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/112.mp3'),
    },
  );

  static final _surah108WithAyat = Surah(
    number: 108,
    arabicName: 'الكوثر',
    latinName: 'Al-Kautsar',
    meaning: 'Nikmat yang Banyak',
    revelation: Revelation.makkiyah,
    ayahCount: 3,
    descriptionPlain: 'Surat Al-Kautsar',
    fullAudio: {
      '05': Uri.parse('https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/108.mp3'),
      '03': Uri.parse('https://cdn.equran.id/audio-full/Abdurrahman-as-Sudais/108.mp3'),
    },
    ayat: [
      Ayah(
        surahNumber: 108,
        number: 1,
        arabic: 'اِنَّآ اَعْطَيْنٰكَ الْكَوْثَرَۗ',
        transliteration: 'Innā a‘ṭainākal-kauṡar(a).',
        translation: 'Sungguh, Kami telah memberimu nikmat yang banyak.',
        audio: {
          '05': Uri.parse('https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/108001.mp3'),
          '03': Uri.parse('https://cdn.equran.id/audio-partial/Abdurrahman-as-Sudais/108001.mp3'),
        },
      ),
      Ayah(
        surahNumber: 108,
        number: 2,
        arabic: 'فَصَلِّ لِرَبِّكَ وَانْحَرْۗ',
        transliteration: 'Faṣalli lirabbika wanḥar.',
        translation: 'Maka laksanakanlah salat karena Tuhanmu, dan berkurbanlah.',
        audio: {
          '05': Uri.parse('https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/108002.mp3'),
          '03': Uri.parse('https://cdn.equran.id/audio-partial/Abdurrahman-as-Sudais/108002.mp3'),
        },
      ),
      Ayah(
        surahNumber: 108,
        number: 3,
        arabic: 'اِنَّ شَانِئَكَ هُوَ الْاَبْتَرُ',
        transliteration: 'Inna syāni\'aka huwal-abtar(u).',
        translation: 'Sungguh, orang-orang yang membencimu dialah yang terputus.',
        audio: {
          '05': Uri.parse('https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/108003.mp3'),
          '03': Uri.parse('https://cdn.equran.id/audio-partial/Abdurrahman-as-Sudais/108003.mp3'),
        },
      ),
    ],
  );

  @override
  Future<List<Surah>> getSurahs({bool forceRefresh = false}) async {
    if (shouldFail) throw const AppFailure(AppFailureKind.offline);
    return [_surah55, _surah108WithAyat, _surah112];
  }

  @override
  Future<Surah> getSurahDetail(int number, {bool forceRefresh = false}) async {
    if (shouldFail) throw const AppFailure(AppFailureKind.offline);
    if (number == 108) return _surah108WithAyat;
    if (number == 112) return _surah112;
    return _surah55;
  }

  @override
  Future<SurahTafsir> getTafsir(int number, {bool forceRefresh = false}) async {
    if (shouldFail) throw const AppFailure(AppFailureKind.offline);
    return SurahTafsir(surahNumber: number, entries: const []);
  }
}

MediaItem _mockItem(String id, {MediaKind kind = MediaKind.adhkar}) =>
    MediaItem(
      id: id,
      kind: kind,
      source: MediaSource.mock,
      title: 'Item $id',
      subtitle: 'Contoh',
      duration: const Duration(minutes: 2),
      audioUri: Uri.parse('asset://assets/audio_samples/sample_01.mp3'),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatDuration', () {
    test('menampilkan --:-- saat null dan mm:ss saat ada durasi', () {
      expect(formatDuration(null), '--:--');
      expect(formatDuration(const Duration(minutes: 4, seconds: 5)), '04:05');
      expect(
        formatRemaining(
          const Duration(minutes: 1),
          const Duration(minutes: 4),
        ),
        '-03:00',
      );
    });
  });

  group('SurahDto parser', () {
    test('menangani surat 1 (suratSebelumnya: false), tag HTML, dan kunci audio asing', () {
      final dto = SurahDto.fromJson({
        'nomor': 1,
        'nama': 'الفاتحة',
        'namaLatin': 'Al-Fatihah',
        'jumlahAyat': 7,
        'tempatTurun': 'Mekah',
        'arti': 'Pembukaan',
        'deskripsi': 'Surat <i>Al Faatihah</i><br>Pembukaan.',
        'audioFull': {
          '05': 'https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/001.mp3',
          '99': 'https://example.com/ignored.mp3',
        },
        'suratSebelumnya': false,
      });

      final domain = dto.toDomain();
      expect(domain.number, 1);
      expect(domain.descriptionPlain, 'Surat Al Faatihah\nPembukaan.');
      expect(domain.fullAudio.keys, ['05']);
      expect(domain.previousSurah, isNull);
      expect(domain.nextSurah, isNull);
    });
  });

  group('PlayQueue', () {
    test('mengacak dan memulihkan urutan asli di sekitar item aktif', () {
      final queue = PlayQueue();
      final items = [_mockItem('1'), _mockItem('2'), _mockItem('3'), _mockItem('4')];
      queue.setItems(items, startIndex: 1);
      expect(queue.current?.id, '2');

      queue.setShuffle(true);
      expect(queue.current?.id, '2');
      expect(queue.items.length, 4);

      queue.setShuffle(false);
      expect(queue.items.map((e) => e.id).toList(), ['1', '2', '3', '4']);
      expect(queue.currentIndex, 1);
    });

    test('menghapus item aktif dan menggeser indeks dengan benar', () {
      final queue = PlayQueue();
      queue.setItems([_mockItem('1'), _mockItem('2'), _mockItem('3')], startIndex: 1);
      queue.removeAt(1);
      expect(queue.current?.id, '3');
      expect(queue.currentIndex, 1);
    });
  });

  group('PlayerController M1', () {
    test('memutar surat dari repositori dan item tiruan', () async {
      final controller = PlayerController(
        engine: SimulatedAudioEngine(),
        quranRepository: _FakeQuranRepository(),
      );
      addTearDown(controller.dispose);

      await controller.playSurah(55, qariId: '05');
      expect(controller.state.phase, PlayerPhase.playing);
      expect(controller.state.current?.id, 'surah:55:05');
      expect(controller.state.queue.length, 3);

      // Putar item tiruan adhkar dan uji skip 15 detik.
      final mock = _mockItem('adhkar:1', kind: MediaKind.adhkar);
      await controller.playItem(mock, queue: [mock]);
      expect(controller.state.phase, PlayerPhase.playing);
      await controller.skip(const Duration(seconds: 15));
      expect(controller.position.position, const Duration(seconds: 15));
    });

    test('previous() kembali ke 0 bila posisi > 3 detik, dan ke item sebelumnya bila <= 3 detik', () async {
      final controller = PlayerController(
        engine: SimulatedAudioEngine(),
        quranRepository: _FakeQuranRepository(),
      );
      addTearDown(controller.dispose);

      final items = [_mockItem('1'), _mockItem('2')];
      await controller.playItem(items[1], queue: items, startIndex: 1);
      await controller.seekTo(const Duration(seconds: 10));

      await controller.previous();
      expect(controller.state.currentIndex, 1);
      expect(controller.position.position, Duration.zero);

      await controller.previous();
      expect(controller.state.currentIndex, 0);
    });

    test('mengubah kecepatan, mode ulang, dan menampilkan error ramah saat offline', () async {
      final controller = PlayerController(
        engine: SimulatedAudioEngine(),
        quranRepository: _FakeQuranRepository(shouldFail: true),
      );
      addTearDown(controller.dispose);

      await controller.setSpeed(1.5);
      expect(controller.state.speed, 1.5);

      controller.cycleRepeat();
      expect(controller.state.repeat, RepeatMode.all);
      controller.cycleRepeat();
      expect(controller.state.repeat, RepeatMode.one);
      controller.cycleRepeat();
      expect(controller.state.repeat, RepeatMode.off);

      await controller.playSurah(55);
      expect(controller.state.phase, PlayerPhase.error);
      expect(controller.state.error?.message, contains('offline'));
    });
  });

  group('Sinkronisasi Native Playlist Per Ayat', () {
    test('playSurah memuat playlist per ayat, berpindah otomatis, jumpToAyah & selectQari akurat', () async {
      final engine = SimulatedAudioEngine();
      final repo = _FakeQuranRepository();
      final controller = PlayerController(
        engine: engine,
        quranRepository: repo,
      );
      addTearDown(controller.dispose);

      // Default playSurah memilih Mode A (MediaKind.ayah) saat audio per ayat ada.
      await controller.playSurah(108, qariId: '05');
      expect(controller.state.phase, PlayerPhase.playing);
      expect(controller.state.current?.kind, MediaKind.ayah);
      expect(controller.state.current?.ayahNumber, 1);
      expect(controller.state.queue.length, 3);

      // Simulasikan ayat 1 selesai -> mesin audio otomatis pindah ke ayat 2.
      engine.completeCurrentTrack();
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.current?.ayahNumber, 2);
      expect(controller.state.currentIndex, 1);

      // SyncEngine menghasilkan ayat tepat (bukan perkiraan).
      final sync = const SyncEngine().resolve(
        surah: _FakeQuranRepository._surah108WithAyat,
        current: controller.state.current,
        pos: controller.position,
      );
      expect(sync.activeAyah, 2);
      expect(sync.isEstimated, isFalse);

      // Lompat instan ke ayat 3.
      final jumped = await controller.jumpToAyah(3);
      expect(jumped, isTrue);
      expect(controller.state.current?.ayahNumber, 3);
      expect(controller.state.currentIndex, 2);

      // Ganti qari mempertahankan posisi ayat aktif (Ayat 3).
      await controller.selectQari('03');
      expect(controller.state.current?.qariId, '03');
      expect(controller.state.current?.ayahNumber, 3);
      expect(controller.state.current?.kind, MediaKind.ayah);
    });

    testWidgets('FullscreenPlayer menampilkan teks ayat sinkron dan badge mode dinamis', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final engine = SimulatedAudioEngine();
      final repo = _FakeQuranRepository();
      final player = PlayerController(engine: engine, quranRepository: repo);
      final reader = ReaderController(repository: repo);
      addTearDown(() {
        player.dispose();
        reader.dispose();
      });

      await player.playSurah(108, qariId: '05');

      await tester.pumpWidget(
        PlayerScope(
          controller: player,
          child: ReaderScope(
            controller: reader,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MediaQuery(
                data: const MediaQueryData(size: Size(390, 844)),
                child: const FullscreenPlayerScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mode A aktif -> badge akurat & teks ayat 1 tampil.
      expect(find.text('Mode Per Ayat · Akurat'), findsOneWidget);
      expect(find.text('AYAT 1 DARI 3'), findsWidgets);
      expect(find.text('اِنَّآ اَعْطَيْنٰكَ الْكَوْثَرَۗ'), findsOneWidget);

      // Ayat 1 selesai -> teks otomatis pindah ke Ayat 2.
      engine.completeCurrentTrack();
      await tester.pumpAndSettle();
      expect(find.text('AYAT 2 DARI 3'), findsWidgets);
      expect(find.text('فَصَلِّ لِرَبِّكَ وَانْحَرْۗ'), findsOneWidget);

      // Beralih ke Mode B (audio surat penuh) -> badge jujur tampil Perkiraan.
      await player.playSurah(108, qariId: '05', preferPerAyah: false);
      await tester.pumpAndSettle();
      expect(find.text('Mode Penuh · Perkiraan'), findsOneWidget);

      await player.stop();
    });
  });
}
