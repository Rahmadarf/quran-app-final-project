import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';

import '../features/player/application/player_controller.dart';
import '../features/quran/application/quran_providers.dart';
import '../features/reader/application/reader_controller.dart';
import 'app_colors.dart';
import 'router.dart';

/// Widget akar. Memakai `WidgetsApp` (bukan `MaterialApp`) karena seluruh
/// komponen UI dibuat kustom dan tidak bergantung pada Material.
class QuranApp extends StatefulWidget {
  const QuranApp({super.key});

  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
  final PlayerController _player = PlayerController();
  final ReaderController _reader = ReaderController();

  @override
  void initState() {
    super.initState();
    unawaited(_player.restore());
    unawaited(_reader.restore());
  }

  @override
  void dispose() {
    _player.dispose();
    _reader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerScope(
      controller: _player,
      child: ReaderScope(
        controller: _reader,
        child: WidgetsApp(
        title: 'Quran Audio',
        color: AppColors.background,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.home,
        onGenerateRoute: onGenerateRoute,
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        ),
        // Mouse dan stylus ikut bisa menggulir di web/desktop.
        builder: (context, child) => ScrollConfiguration(
          behavior: const _AppScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      ),
    );
  }
}

class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
