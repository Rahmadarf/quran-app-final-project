import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Daftar ikon yang diekspor dari Figma, disimpan di `assets/icons/`.
enum AppIcons {
  home,
  homeFilled,
  quran,
  compass,
  compassFilled,
  library,
  libraryFilled,
  search,
  mic,
  arrowForward,
  chevronRight,
  chevronDown,
  arrowBack,
  share,
  play,
  playOutline,
  playCircle,
  pause,
  next,
  previous,
  shuffle,
  repeat,
  repeatOne,
  heart,
  heartFilled,
  offlineDone,
  volume,
  bookmark,
  bookmarkFilled,
  copy,
  moreVert,
  add,
  sort,
  headphones,
  timer,
  shield,
  quote,
  podcast,
  playlistAdd,
  qari,
  adhkar,
  tafsir,
  scroll,
  leaf,
  textSize,
  mushaf,
  sparkle,
  check;

  String get asset => 'assets/icons/${_fileName(name)}.svg';

  /// `homeFilled` menjadi `home_filled`.
  static String _fileName(String camel) => camel.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m[0]!.toLowerCase()}',
      );
}

/// Ikon SVG satu warna. Warna asli dari berkas diganti dengan [color].
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 20,
    required this.color,
  });

  final AppIcons icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        icon.asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
