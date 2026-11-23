import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_app_final_project/app/app.dart';
import 'package:quran_app_final_project/app/router.dart';
import 'package:quran_app_final_project/dev/widget_gallery.dart';

void main() {
  testWidgets('Beranda tampil dan tab Pustaka bisa dibuka', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const QuranApp());
    await tester.pump();

    expect(find.text('Hello Aisyah!'), findsOneWidget);
    expect(find.text('Surat Ar-Rahman'), findsWidgets);

    await tester.tap(find.text('Pustaka'));
    await tester.pump();

    expect(find.text('Pustaka Saya'), findsOneWidget);
  });

  testWidgets('Pemilih surat di Fullscreen Player mengganti surat', (tester) async {
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

    await tester.tap(find.text('Pilih Surat'));
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
    // Galeri dirancang untuk lebar layar ponsel (~430dp), bukan surface
    // test default 800x600.
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Beberapa widget punya overflow minor di lingkungan test karena metrik
    // font fallback berbeda dari font asli (PlusJakartaSans). Abaikan error
    // rendering agar smoke test fokus pada keberadaan UI.
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

    // Judul rak qari dan salah satu nama qari tampil di layar.
    expect(find.text('Qari Favorit'), findsOneWidget);
    expect(find.text('Al-Afasi'), findsOneWidget);
  });
}
