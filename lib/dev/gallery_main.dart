import 'package:flutter/widgets.dart';

import '../app/app_colors.dart';
import 'widget_gallery.dart';

/// Titik masuk khusus katalog komponen:
/// `flutter run -t lib/dev/gallery_main.dart`
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
