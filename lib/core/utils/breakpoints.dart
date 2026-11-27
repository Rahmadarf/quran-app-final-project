import 'package:flutter/widgets.dart';

/// Kelas ukuran layar responsif sesuai docs/07 §0.1.
enum ScreenClass {
  /// Ponsel potret: lebar < 600 dp.
  compact,

  /// Tablet potret / ponsel lanskap lebar: 600–839 dp.
  medium,

  /// Tablet lanskap / desktop / web lebar: ≥ 840 dp.
  expanded,
}

/// Utilitas titik patah (breakpoint) dan tata letak responsif.
abstract final class AppBreakpoints {
  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 840;

  static ScreenClass fromWidth(double width) {
    if (width >= expandedMinWidth) return ScreenClass.expanded;
    if (width >= mediumMinWidth) return ScreenClass.medium;
    return ScreenClass.compact;
  }

  static ScreenClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static double horizontalPadding(ScreenClass screenClass) {
    switch (screenClass) {
      case ScreenClass.compact:
        return 16;
      case ScreenClass.medium:
        return 24;
      case ScreenClass.expanded:
        return 32;
    }
  }

  static double contentMaxWidth(ScreenClass screenClass) {
    switch (screenClass) {
      case ScreenClass.compact:
        return double.infinity;
      case ScreenClass.medium:
        return 720;
      case ScreenClass.expanded:
        return 960;
    }
  }
}
