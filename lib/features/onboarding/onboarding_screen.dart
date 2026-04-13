import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_builders/core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _skipPressed = false;

  // Exit animation
  late AnimationController _exitCtrl;
  late Animation<double> _exitFade;
  late Animation<Offset> _exitSlide;
  late Animation<double> _exitScale;

  // Floating particle animation
  late AnimationController _particleCtrl;

  static const _pages = [
    _OPage(
      emoji: '🏙️',
      title: 'Welcome to\nWorld Builders!',
      body:
          'Build your very own town by answering fun questions across Maths, Reading, Science and Life Skills.',
      bg: Color(0xFF1565C0),        // rich sky blue
      accent: Color(0xFFFFD54F),    // warm golden yellow
      accentDark: Color(0xFFFFA000),
    ),
    _OPage(
      emoji: '🧱',
      title: 'Earn Bricks!',
      body:
          'Every correct answer earns you a brick. Collect enough bricks to unlock new buildings in your town.',
      bg: Color(0xFFE65100),        // vibrant warm orange
      accent: Color(0xFFFFECB3),    // light amber
      accentDark: Color(0xFFFFCA28),
    ),
    _OPage(
      emoji: '🎯',
      title: 'Daily Challenge!',
      body:
          'Answer questions to fill your 5×5 challenge board. Complete a line to win bonus bricks. Board resets every day!',
      bg: Color(0xFF6A1B9A),        // rich purple
      accent: Color(0xFFE1BEE7),    // soft lilac
      accentDark: Color(0xFFCE93D8),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _exitCtrl,
          curve: const Interval(0.3, 1.0, curve: Curves.easeInCubic)),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.10),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic));
    _exitScale = Tween(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic),
    );

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await _exitCtrl.forward();
    if (!mounted) return;
    widget.onComplete();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: page.bg,
      body: FadeTransition(
        opacity: _exitFade,
        child: ScaleTransition(
          scale: _exitScale,
          child: SlideTransition(
            position: _exitSlide,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic,
              color: page.bg,
              child: SafeArea(
                child: Stack(
                  children: [
                    // Floating particles background
                    _FloatingParticles(
                      controller: _particleCtrl,
                      color: page.accent,
                    ),

                    Column(
                      children: [
                        // ── Top bar ──────────────────────────
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              // Back arrow
                              AnimatedOpacity(
                                opacity: _currentPage > 0 ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: GestureDetector(
                                  onTap: _prev,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.22),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.35)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.arrow_back_rounded,
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                        size: 18),
                                  ),
                                ),
                              ),

                              // Page indicator dots
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(_pages.length,
                                    (i) {
                                  final active = i == _currentPage;
                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width: active ? 22 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Colors.white
                                          : Colors.white
                                              .withValues(alpha: 0.35),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      boxShadow: active
                                          ? [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 8,
                                              )
                                            ]
                                          : [],
                                    ),
                                  );
                                }),
                              ),

                              // Skip button
                              GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => _skipPressed = true),
                                onTapUp: (_) {
                                  setState(() => _skipPressed = false);
                                  _finish();
                                },
                                onTapCancel: () =>
                                    setState(() => _skipPressed = false),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 150),
                                  transform: Matrix4.identity()
                                    ..scale(
                                        _skipPressed ? 0.92 : 1.0),
                                  transformAlignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _skipPressed
                                        ? Colors.white
                                            .withValues(alpha: 0.16)
                                        : Colors.white
                                            .withValues(alpha: 0.08),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _skipPressed
                                          ? Colors.white
                                              .withValues(alpha: 0.3)
                                          : Colors.white
                                              .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Text(
                                    'Skip',
                                    style: WBText.body(13,
                                        color: Colors.white.withValues(
                                            alpha:
                                                _skipPressed ? 0.9 : 0.6),
                                        weight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Page content ──────────────────────
                        Expanded(
                          child: PageView.builder(
                            controller: _controller,
                            onPageChanged: (i) =>
                                setState(() => _currentPage = i),
                            itemCount: _pages.length,
                            itemBuilder: (_, i) =>
                                _PageContent(page: _pages[i]),
                          ),
                        ),

                        // ── Bottom CTA ────────────────────────
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 44),
                          child: _CTAButton(
                            label:
                                isLast ? "Let's Build! 🚀" : 'Next →',
                            color: page.accent,
                            shadowColor: page.accentDark,
                            onTap: _next,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Floating particles ────────────────────────────────────────────────────────

class _FloatingParticles extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  const _FloatingParticles(
      {required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            progress: controller.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  _ParticlePainter({required this.progress, required this.color});

  static final _rng = math.Random(42);
  static final _particles = List.generate(18, (i) => [
    _rng.nextDouble(), // x seed
    _rng.nextDouble(), // y seed
    _rng.nextDouble() * 0.6 + 0.2, // size seed
    _rng.nextDouble(), // phase offset
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final phase = (progress + p[3]) % 1.0;
      final x = p[0] * size.width;
      final y = size.height - (phase * (size.height + 60)) + 30;
      final radius = (p[2] * 3.5 + 1.0);
      final opacity = (math.sin(phase * math.pi) * 0.25).clamp(0.0, 0.25);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.color != color;
}

// ── CTA button ────────────────────────────────────────────────────────────────

class _CTAButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;
  const _CTAButton({
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressing = true);
        _ctrl.forward();
      },
      onTapUp: (_) {
        setState(() => _pressing = false);
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressing = false);
        _ctrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 19),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color,
                widget.shadowColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withValues(alpha: _pressing ? 0.22 : 0.45),
                blurRadius: _pressing ? 10 : 28,
                offset: Offset(0, _pressing ? 3 : 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: WBText.body(17,
                color: Colors.white, weight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

// ── Page data ─────────────────────────────────────────────────────────────────

class _OPage {
  final String emoji;
  final String title;
  final String body;
  final Color bg;
  final Color accent;
  final Color accentDark;
  const _OPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.bg,
    required this.accent,
    required this.accentDark,
  });
}

// ── Page content ──────────────────────────────────────────────────────────────

class _PageContent extends StatefulWidget {
  final _OPage page;
  const _PageContent({super.key, required this.page});

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.55, end: 1.0));
    _fade = CurvedAnimation(
            parent: _anim,
            curve: const Interval(0, 0.6, curve: Curves.easeOut))
        .drive(Tween(begin: 0.0, end: 1.0));
    _slide = CurvedAnimation(
            parent: _anim,
            curve: const Interval(0.1, 0.7, curve: Curves.easeOut))
        .drive(Tween(
            begin: const Offset(0, 0.12), end: Offset.zero));
    _glowPulse = CurvedAnimation(
            parent: _anim, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Emoji illustration ──────────────────────
          ScaleTransition(
            scale: _scale,
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (_, child) => Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.page.accent.withValues(alpha: 0.10),
                  border: Border.all(
                    color: widget.page.accent
                        .withValues(alpha: 0.25 * _glowPulse.value),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.page.accent
                          .withValues(alpha: 0.25 * _glowPulse.value),
                      blurRadius: 50,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: widget.page.accent
                          .withValues(alpha: 0.10 * _glowPulse.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: child,
              ),
              child: Text(widget.page.emoji,
                  style: const TextStyle(fontSize: 72)),
            ),
          ),

          const SizedBox(height: 48),

          // ── Text content ────────────────────────────
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                children: [
                  Text(
                    widget.page.title,
                    style: WBText.display(30,
                        color: Colors.white, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // Body in a glass card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30)),
                    ),
                    child: Text(
                      widget.page.body,
                      style: WBText.body(15,
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

Future<bool> needsOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool('onboarding_complete') ?? false);
}
