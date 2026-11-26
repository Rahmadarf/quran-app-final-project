import 'package:flutter/widgets.dart';

import '../features/catalog/presentation/explore_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/application/player_providers.dart';
import '../features/player/presentation/mini_player.dart';
import '../features/player/presentation/player_bar.dart';
import '../features/player/presentation/queue_sheet.dart';
import '../features/player/presentation/sleep_timer_sheet.dart';
import '../features/player/presentation/speed_sheet.dart';
import '../features/quran/presentation/surah_list_screen.dart';
import '../shared/widgets/app_icon.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/icon_circle_button.dart';
import 'app_colors.dart';
import 'router.dart';

/// Cangkang aplikasi: empat tab, Mini Player (Compact/Medium) atau Player Bar
/// (Expanded >= 840 dp) di atas/bawah bilah navigasi (docs/05 §1, 07 §0.1).
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
    final current = player.state.current;
    final isExpanded = MediaQuery.sizeOf(context).width >= 840;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                HomeScreen(),
                SurahListScreen(),
                ExploreScreen(),
                LibraryScreen(),
              ],
            ),
          ),
          if (isExpanded)
            PlayerBar(
              onExpand: () => Navigator.of(context).pushNamed(AppRoutes.player),
              onQueueTap: () => showQueueSheet(context, player),
              onSpeedTap: () => showSpeedSheet(context, player),
              onSleepTap: () => showSleepTimerSheet(context, player),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: RepaintBoundary(
                child: PlaybackPositionBuilder(
                  positionListenable: player.positionListenable,
                  builder: (context, pos) => MiniPlayer(
                    leading: MiniPlayerLeading.image(
                      AssetImage(
                        current?.artwork ??
                            'assets/images/covers/ar-rahman.png',
                      ),
                    ),
                    title: current?.title ?? 'Surat Ar-Rahman',
                    subtitle: current?.subtitle ?? 'Misyari Rasyid Al-Afasi',
                    progress: pos.progress,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.player),
                    actions: [
                      IconCircleButton(
                        icon: player.favorite
                            ? AppIcons.heartFilled
                            : AppIcons.heart,
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
