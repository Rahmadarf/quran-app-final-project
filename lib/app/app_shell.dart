import 'package:flutter/widgets.dart';

import '../features/catalog/presentation/explore_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/application/player_controller.dart';
import '../features/player/presentation/mini_player.dart';
import '../shared/widgets/app_icon.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/icon_circle_button.dart';
import 'app_colors.dart';
import 'router.dart';

/// Cangkang aplikasi: empat tab, Mini Player di atas bilah navigasi, dan
/// isi tab yang tetap hidup saat berpindah (posisi gulir terjaga).
///
/// Baru layout ponsel (compact) yang dirancang di Figma. Rel dan sidebar untuk
/// layar lebar (docs/07 §0.1) belum ada.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                const HomeScreen(),
                EmptyState(
                  icon: AppIcons.quran,
                  title: 'Daftar surat segera hadir',
                  message:
                      'Layar ini belum ada di desain Figma. Buka Reader lewat tombol di bawah.',
                  actionLabel: 'Buka Surat Ar-Rahman',
                  onAction: () =>
                      Navigator.of(context).pushNamed(AppRoutes.reader),
                ),
                const ExploreScreen(),
                const LibraryScreen(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: MiniPlayer(
              leading: const MiniPlayerLeading.image(
                AssetImage('assets/images/covers/ar-rahman.png'),
              ),
              title: 'Surat Ar-Rahman',
              subtitle: 'Misyari Rasyid Al-Afasi',
              progress: player.progress,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.player),
              actions: [
                IconCircleButton(
                  icon: player.favorite ? AppIcons.heartFilled : AppIcons.heart,
                  semanticLabel: player.favorite
                      ? 'Hapus dari favorit'
                      : 'Favoritkan',
                  size: 32,
                  iconSize: 16,
                  iconColor: player.favorite
                      ? AppColors.accent
                      : AppColors.textMuted,
                  onTap: player.toggleFavorite,
                ),
                IconCircleButton(
                  icon: player.playing ? AppIcons.pause : AppIcons.play,
                  semanticLabel: player.playing ? 'Jeda' : 'Putar',
                  style: IconCircleStyle.primary,
                  size: 32,
                  iconSize: 11,
                  onTap: player.togglePlay,
                ),
              ],
            ),
          ),
          AppBottomNavBar(
            items: AppBottomNavBar.defaultItems,
            currentIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        ],
      ),
    );
  }
}
