import 'dart:math';

import '../../../app/constants.dart';
import 'media_item.dart';
import 'player_state.dart';

/// Pengelola antrean pemutar dengan dukungan acak yang mempertahankan urutan
/// asli serta batas maksimal [AppConstants.maxQueueLength] item (docs/05 §5).
class PlayQueue {
  PlayQueue({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<MediaItem> _original = [];
  List<MediaItem> _active = [];
  int _currentIndex = -1;
  bool _shuffled = false;
  String? _source;

  List<MediaItem> get items => List.unmodifiable(_active);
  int get currentIndex => _currentIndex;
  bool get isEmpty => _active.isEmpty;
  int get length => _active.length;
  bool get isShuffled => _shuffled;
  String? get source => _source;

  MediaItem? get current =>
      (_currentIndex >= 0 && _currentIndex < _active.length)
          ? _active[_currentIndex]
          : null;

  /// Mengisi antrean baru dan menunjuk [startIndex] sebagai item aktif.
  /// Mengembalikan `true` bila daftar melebihi batas dan dipotong.
  bool setItems(
    List<MediaItem> items, {
    int startIndex = 0,
    bool shuffle = false,
    String? source,
  }) {
    final truncated = items.length > AppConstants.maxQueueLength;
    final bounded = truncated
        ? items.sublist(0, AppConstants.maxQueueLength)
        : List<MediaItem>.of(items);

    _original = List<MediaItem>.of(bounded);
    _source = source;
    _shuffled = shuffle;

    if (bounded.isEmpty) {
      _active = [];
      _currentIndex = -1;
      return truncated;
    }

    final safeIndex = startIndex.clamp(0, bounded.length - 1);
    final target = bounded[safeIndex];

    if (shuffle) {
      _active = _buildShuffledAround(bounded, target);
      _currentIndex = 0;
    } else {
      _active = List<MediaItem>.of(bounded);
      _currentIndex = safeIndex;
    }
    return truncated;
  }

  /// Menambah item di akhir antrean. Mengembalikan `false` jika penuh.
  bool enqueue(MediaItem item) {
    if (_active.length >= AppConstants.maxQueueLength) return false;
    _original.add(item);
    _active.add(item);
    if (_currentIndex == -1) _currentIndex = 0;
    return true;
  }

  /// Menyisipkan item tepat setelah item aktif. Mengembalikan `false` jika penuh.
  bool playNext(MediaItem item) {
    if (_active.length >= AppConstants.maxQueueLength) return false;
    if (_active.isEmpty || _currentIndex < 0) {
      return enqueue(item);
    }
    final insertAt = (_currentIndex + 1).clamp(0, _active.length);
    _active.insert(insertAt, item);
    final currentItem = _active[_currentIndex];
    final origIdx = _original.indexOf(currentItem);
    if (origIdx >= 0) {
      _original.insert(origIdx + 1, item);
    } else {
      _original.add(item);
    }
    return true;
  }

  /// Menghapus item pada [index]. Mengembalikan item baru yang aktif jika item
  /// aktif yang terhapus.
  void removeAt(int index) {
    if (index < 0 || index >= _active.length) return;
    final removed = _active.removeAt(index);
    _original.remove(removed);

    if (_active.isEmpty) {
      _currentIndex = -1;
      return;
    }
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex) {
      _currentIndex = _currentIndex.clamp(0, _active.length - 1);
    }
  }

  /// Memindahkan item dari [oldIndex] ke [newIndex] (gaya ReorderableList).
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _active.length ||
        newIndex < 0 ||
        newIndex >= _active.length ||
        oldIndex == newIndex) {
      return;
    }
    final activeItem = current;
    final moved = _active.removeAt(oldIndex);
    _active.insert(newIndex, moved);
    if (!_shuffled) {
      _original = List<MediaItem>.of(_active);
    }
    if (activeItem != null) {
      _currentIndex = _active.indexOf(activeItem);
    }
  }

  /// Mengaktifkan/mematikan acak dengan mempertahankan item aktif sekarang.
  void setShuffle(bool enabled) {
    if (_shuffled == enabled) return;
    _shuffled = enabled;
    final activeItem = current;
    if (_active.isEmpty || activeItem == null) return;

    if (enabled) {
      _active = _buildShuffledAround(_original, activeItem);
      _currentIndex = 0;
    } else {
      _active = List<MediaItem>.of(_original);
      final idx = _active.indexOf(activeItem);
      _currentIndex = idx >= 0 ? idx : 0;
    }
  }

  void jumpTo(int index) {
    if (index >= 0 && index < _active.length) {
      _currentIndex = index;
    }
  }

  /// Indeks berikutnya sesuai [repeat], atau `null` bila antrean selesai.
  int? nextIndex(RepeatMode repeat) {
    if (_active.isEmpty) return null;
    if (repeat == RepeatMode.one) return _currentIndex;
    if (_currentIndex + 1 < _active.length) {
      return _currentIndex + 1;
    }
    if (repeat == RepeatMode.all) return 0;
    return null;
  }

  /// Indeks sebelumnya sesuai [repeat], atau `null` bila di awal.
  int? previousIndex(RepeatMode repeat) {
    if (_active.isEmpty) return null;
    if (repeat == RepeatMode.one) return _currentIndex;
    if (_currentIndex - 1 >= 0) {
      return _currentIndex - 1;
    }
    if (repeat == RepeatMode.all) return _active.length - 1;
    return null;
  }

  void clear() {
    _original.clear();
    _active.clear();
    _currentIndex = -1;
    _source = null;
  }

  List<MediaItem> _buildShuffledAround(
    List<MediaItem> source,
    MediaItem activeItem,
  ) {
    final rest = source.where((item) => item != activeItem).toList();
    rest.shuffle(_random);
    return [activeItem, ...rest];
  }
}
