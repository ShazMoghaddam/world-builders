import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
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
        onTap: switchTab,
      ),
    );
  }
}

// ── Nav item data ─────────────────────────────────────────────────────────────

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData iconSelected;
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.iconSelected,
  });
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _WBBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _WBBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItemData(
      label: 'Town',
      icon: Icons.location_city_outlined,
      iconSelected: Icons.location_city_rounded,
    ),
    _NavItemData(
      label: 'Play',
      icon: Icons.sports_esports_outlined,
      iconSelected: Icons.sports_esports_rounded,
    ),
    _NavItemData(
      label: 'Challenge',
      icon: Icons.grid_view_outlined,
      iconSelected: Icons.grid_view_rounded,
    ),
    _NavItemData(
      label: 'Me',
      icon: Icons.person_outline_rounded,
      iconSelected: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WBColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: WBColors.lifePurple.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(
              _items.length,
              (i) => Expanded(
                child: _NavButton(
                  item: _items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
            ),
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
  const _NavButton(
      {required this.item, required this.selected, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _iconScale = Tween(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(_NavButton old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final color = selected ? WBColors.lifePurple : WBColors.locked;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill indicator with icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFFD580FF), Color(0xFFBF5AF2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: WBColors.lifePurple.withValues(alpha: 0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: AnimatedBuilder(
                animation: _iconScale,
                builder: (_, child) => Transform.scale(
                  scale: selected ? _iconScale.value : 1.0,
                  child: child,
                ),
                child: Icon(
                  selected ? widget.item.iconSelected : widget.item.icon,
                  color: selected ? Colors.white : WBColors.locked,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: WBTextStyles.label.copyWith(
                color: color,
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w600,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}
