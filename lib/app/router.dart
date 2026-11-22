import 'package:flutter/widgets.dart';

import '../features/player/presentation/fullscreen_player.dart';
import '../features/reader/presentation/reader_screen.dart';
import 'app_shell.dart';

/// Nama rute (docs/07 §1.2). Router ini sementara memakai `Navigator` bawaan;
/// diganti `go_router` bila keputusan stack navigasi sudah final.
abstract final class AppRoutes {
  static const String home = '/';
  static const String reader = '/quran/55';
  static const String player = '/putar';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.player:
      return _slideUp(settings, const FullscreenPlayerScreen());
    case AppRoutes.reader:
      return _fade(settings, const ReaderScreen());
    case AppRoutes.home:
    default:
      return _fade(settings, const AppShell());
  }
}

PageRoute<T> _fade<T>(RouteSettings settings, Widget page) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Fullscreen Player naik dari bawah seperti lembar modal.
PageRoute<T> _slideUp<T>(RouteSettings settings, Widget page) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero)
            .animate(curved),
        child: child,
      );
    },
  );
}
