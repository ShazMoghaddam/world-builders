import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/widgets/wb_icons.dart';
import 'core/services/audio_service.dart';
import 'providers/app_state.dart';
import 'data/repositories/question_repository.dart';
import 'features/play/providers/game_state.dart';
import 'features/bingo/providers/bingo_state.dart';
import 'features/town/town_screen.dart';
import 'features/play/play_screen.dart';
import 'features/bingo/bingo_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.load();
  final questionRepo = QuestionRepository();
  final gameState = GameState(questionRepo);
  final bingoState = BingoState();
  final audioService = AudioService();
  final showOnboarding = await needsOnboarding();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: gameState),
        ChangeNotifierProvider.value(value: bingoState),
        Provider.value(value: questionRepo),
        ChangeNotifierProvider.value(value: audioService),
      ],
      child: WorldBuildersApp(showOnboarding: showOnboarding),
    ),
  );
}

class WorldBuildersApp extends StatelessWidget {
  final bool showOnboarding;
  const WorldBuildersApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Builders',
      theme: WBTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => showOnboarding
                ? OnboardingScreen(onComplete: () {
                    Navigator.of(_).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => AppShell(key: appShellKey),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 600),
                      ),
                    );
                  })
                : AppShell(key: appShellKey),
            transitionDuration: Duration.zero,
          );
        }
        return null;
      },
    );
  }
}

/// Global key so Town (and any screen) can switch tabs without a Navigator push.
final appShellKey = GlobalKey<_AppShellState>();

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    TownScreen(),
    PlayScreen(),
    BingoScreen(),
    ProfileScreen(),
  ];

  void switchTab(int index) {
    // Reset game if navigating away mid-session
    if (_currentIndex == 1 && index != 1) {
      final game = appShellKey.currentContext?.read<GameState>();
      if (game != null && game.phase != GamePhase.idle) {
        game.reset();
      }
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _WBBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final Widget Function(Color color, double size) icon;
  const _NavItemData({required this.label, required this.icon});
}

class _WBBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _WBBottomNav({required this.currentIndex, required this.onTap});

  static final _items = [
    _NavItemData(label: 'Town',  icon: (c, s) => Icon(Icons.location_city_rounded, color: c, size: s)),
    _NavItemData(label: 'Play',  icon: (c, s) => Icon(Icons.sports_esports_rounded, color: c, size: s)),
    _NavItemData(label: 'Bingo', icon: (c, s) => Icon(Icons.grid_view_rounded, color: c, size: s)),
    _NavItemData(label: 'Me',    icon: (c, s) => Icon(Icons.person_rounded, color: c, size: s)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WBColors.cardWhite,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length,
                (i) => Expanded(child: _NavButton(
                  item: _items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ))),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({required this.item, required this.selected, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final color = selected ? WBColors.lifePurple : WBColors.locked;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? WBColors.lifePurpleLight : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: widget.item.icon(color, 22),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: WBTextStyles.label.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}
