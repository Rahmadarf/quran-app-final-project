import 'package:flutter/widgets.dart';

import '../../reader/application/reader_controller.dart';

/// Menyediakan [ReaderController] ke seluruh pohon widget.
class ReaderScope extends InheritedNotifier<ReaderController> {
  const ReaderScope({
    super.key,
    required ReaderController controller,
    required super.child,
  }) : super(notifier: controller);

  static ReaderController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ReaderScope>();
    assert(scope != null, 'ReaderScope tidak ditemukan di atas widget ini');
    return scope!.notifier!;
  }

  static ReaderController read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<ReaderScope>();
    final scope = element?.widget as ReaderScope?;
    assert(scope != null, 'ReaderScope tidak ditemukan di atas widget ini');
    return scope!.notifier!;
  }
}
