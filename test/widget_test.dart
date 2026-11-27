import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_app_final_project/app/app.dart';
import 'package:quran_app_final_project/app/router.dart';
import 'package:quran_app_final_project/app/theme.dart';
import 'package:quran_app_final_project/dev/widget_gallery.dart';
import 'package:quran_app_final_project/shared/widgets/theme_toggle_fab.dart';

void main() {
  testWidgets('Beranda tampil, tab Pustaka & Detail Koleksi bisa dibuka',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const QuranApp());
    await tester.pump();

    expect(find.text("Assalamu'alaikum, Aisyah"), findsOneWidget);
    expect(find.text('Surat Ar-Rahman'), findsWidgets);

    await tester.tap(find.text('Pustaka'));
    await tester.pump();

    expect(find.text('Pustaka Saya'), findsOneWidget);

    // Buka halaman Detail Koleksi (Surat Populer 2024)
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(AppRoutes.collection);
    await tester.pumpAndSettle();
    expect(find.text('Surat Populer 2024'), findsOneWidget);
    expect(find.text('Daftar Tilawah'), findsOneWidget);
  });

  testWidgets('Tombol ganti tema mengambang beralih antara Dark dan Light Mode',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const QuranApp());
    await tester.pump();

    expect(find.byType(FloatingThemeToggle), findsOneWidget);
    // Bawaan Audiophile Obsidian Dark -> tombol menawarkan "Terang".
    expect(find.text('Terang'), findsOneWidget);
    final ctx = tester.element(find.byType(FloatingThemeToggle));
    expect(AppThemeScope.paletteOf(ctx).brightness, Brightness.dark);

    // Ketuk tombol mengambang -> berpindah ke Studio Light.
    await tester.tap(find.byType(FloatingThemeToggle));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Gelap'), findsOneWidget);
    expect(AppThemeScope.paletteOf(ctx).brightness, Brightness.light);

    // Ketuk lagi -> kembali ke Dark Mode.
    await tester.tap(find.byType(FloatingThemeToggle));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Terang'), findsOneWidget);
    expect(AppThemeScope.paletteOf(ctx).brightness, Brightness.dark);
  });

  testWidgets('Pemilih surat di Fullscreen Player mengganti surat',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const QuranApp());
    await tester.pump();

    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(AppRoutes.player);
    await tester.pumpAndSettle();
    expect(find.text('Surat Ar-Rahman'), findsWidgets);

    final pilihSurat = find.text('Pilih Surat');
    await tester.ensureVisible(pilihSurat);
    await tester.pumpAndSettle();
    await tester.tap(pilihSurat);
    await tester.pumpAndSettle();
    expect(find.text('Pilih surat'), findsOneWidget);

    await tester.tap(find.text('Al-Kahf'));
    await tester.pumpAndSettle();

    // Panel tertutup dan surat berganti; ayat kembali ke 1.
    expect(find.text('Pilih surat'), findsNothing);
    expect(find.text('Surat Al-Kahf'), findsOneWidget);
    expect(find.text('AYAT 1 DARI 110'), findsOneWidget);
  });

  testWidgets('Galeri widget menampilkan rak Qari Favorit', (tester) async {
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.library == 'rendering library') return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: WidgetGallery(),
      ),
    );

    expect(find.text('Qari Favorit'), findsOneWidget);
    expect(find.text('Al-Afasi'), findsOneWidget);
  });
}
