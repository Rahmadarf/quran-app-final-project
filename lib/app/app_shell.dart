import 'package:flutter/widgets.dart';

import '../core/utils/breakpoints.dart';
import '../features/catalog/presentation/explore_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/application/player_providers.dart';
import '../features/player/domain/media_item.dart';
import '../features/player/presentation/mini_player.dart';
import '../features/player/presentation/player_bar.dart';
import '../features/player/presentation/queue_sheet.dart';
import '../features/player/presentation/sleep_timer_sheet.dart';
import '../features/player/presentation/speed_sheet.dart';
import '../features/quran/presentation/surah_list_screen.dart';
import '../shared/widgets/app_icon.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/icon_circle_button.dart';
import 'router.dart';
import 'theme.dart';

/// Cangkang aplikasi dual-mode: empat tab, Mini Player (Compact/Medium) atau
/// Player Bar (Expanded >= 840 dp) di atas bilah navigasi.
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
    final screenClass = AppBreakpoints.of(context);
    final isExpanded = screenClass == ScreenClass.expanded;
    final palette = AppThemeScope.paletteOf(context);

    return ColoredBox(
      color: palette.background,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                TickerMode(enabled: _tab == 0, child: const HomeScreen()),
                TickerMode(enabled: _tab == 1, child: const SurahListScreen()),
                TickerMode(enabled: _tab == 2, child: const ExploreScreen()),
                TickerMode(enabled: _tab == 3, child: const LibraryScreen()),
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
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: RepaintBoundary(
                child: PlaybackPositionBuilder(
                  positionListenable: player.positionListenable,
                  builder: (context, pos) {
                    final isAyah = current?.kind == MediaKind.ayah;
                    final surahLatin =
                        current?.meta['surahLatinName'] as String?;
                    final miniTitle = isAyah && surahLatin != null
                        ? 'Surat $surahLatin'
                        : (current?.title ?? 'Surat Ar-Rahman');
                    final miniSubtitle = isAyah && current?.ayahNumber != null
                        ? 'Ayat ${current!.ayahNumber} · ${current.subtitle}'
                        : (current?.subtitle ?? player.selectedQariName);
                    final miniProgress = isAyah &&
                            current?.ayahNumber != null &&
                            (current?.ayahCount ?? 0) > 0
                        ? (current!.ayahNumber! / current.ayahCount!)
                            .clamp(0.0, 1.0)
                        : pos.progress;
                    return MiniPlayer(
                      leading: MiniPlayerLeading.image(
                        AssetImage(
                          current?.artwork ??
                              'assets/images/covers/ar-rahman.png',
                        ),
                      ),
                      title: miniTitle,
                      subtitle: miniSubtitle,
                      progress: miniProgress,
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
                          size: 34,
                          iconSize: 17,
                          iconColor: player.favorite
                              ? palette.accent
                              : palette.textMuted,
                          onTap: player.toggleFavorite,
                        ),
                        IconCircleButton(
                          icon: player.playing ? AppIcons.pause : AppIcons.play,
                          semanticLabel: player.playing ? 'Jeda' : 'Putar',
                          style: IconCircleStyle.primary,
                          size: 34,
                          iconSize: 13,
                          onTap: player.togglePlay,
                        ),
                      ],
                    );
                  },
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
