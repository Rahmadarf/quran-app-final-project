import 'package:flutter/widgets.dart';

import 'app/app_colors.dart';
import 'dev/widget_gallery.dart';

/// Titik masuk aplikasi.
///
/// Sementara ini langsung menampilkan [WidgetGallery] karena layar Beranda
/// asli (lib/features/home/presentation/home_screen.dart) belum
/// diimplementasikan. Ganti `home` ke HomeScreen setelah layar tersebut jadi.
void main() {
  runApp(
    WidgetsApp(
      color: AppColors.background,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: const WidgetGallery(),
    ),
  );
}
