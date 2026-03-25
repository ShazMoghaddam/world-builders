import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _skipPressed = false;

  // Exit animation — whole screen fades + slides up when leaving
  late AnimationController _exitCtrl;
  late Animation<double> _exitFade;
  late Animation<Offset> _exitSlide;
  late Animation<double> _exitScale;

  static const _pages = [
    _OPage(
      emoji: '🏙️',
      title: 'Welcome to\nWorld Builders!',
      body: 'Build your very own town by answering fun questions across Maths, Reading, Science and Life Skills.',
      bg: Color(0xFF0F0E17),
      accent: Color(0xFF378ADD),
    ),
    _OPage(
      emoji: '🧱',
      title: 'Earn Bricks!',
      body: 'Every correct answer earns you a brick. Collect enough bricks to unlock new buildings in your town.',
      bg: Color(0xFF160E08),
      accent: Color(0xFFE8593C),
    ),
    _OPage(
      emoji: '🎯',
      title: 'Play Daily Bingo!',
      body: 'Answer questions to fill your 5×5 Bingo board. Complete a line to win bonus bricks. Board resets every day!',
      bg: Color(0xFF100F1A),
      accent: Color(0xFF7F77DD),
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
      CurvedAnimation(parent: _exitCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeInCubic)),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.12),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic));
    _exitScale = Tween(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!mounted) return;
    // Save BEFORE animation — prevents re-showing if force-closed mid-animation
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await _exitCtrl.forward();
    if (!mounted) return;
    widget.onComplete();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
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
            child: SafeArea(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                color: page.bg,
              child: Column(
                children: [
                  // ── Top bar ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back arrow
                        AnimatedOpacity(
                          opacity: _currentPage > 0 ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTap: _prev,
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.arrow_back_rounded,
                                  color: Colors.white.withValues(alpha: 0.7), size: 18),
                            ),
                          ),
                        ),

                        // Skip button with press animation
                        GestureDetector(
                          onTapDown: (_) => setState(() => _skipPressed = true),
                          onTapUp: (_) {
                            setState(() => _skipPressed = false);
                            _finish();
                          },
                          onTapCancel: () => setState(() => _skipPressed = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            transform: Matrix4.identity()
                              ..scale(_skipPressed ? 0.92 : 1.0),
                            transformAlignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _skipPressed
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _skipPressed
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white
                                    .withValues(alpha: _skipPressed ? 0.9 : 0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Page content ──────────────────────────
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

                  // ── Bottom controls ───────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      children: [
                        // Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (i) {
                            final active = i == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: active
                                    ? page.accent
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 28),

                        // CTA button
                        _CTAButton(
                          label: isLast ? "Let's Build! 🚀" : "Next →",
                          color: page.accent,
                          onTap: _next,
                        ),
                      ],
                    ),
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

// ── CTA button with press animation ──────────────────────────────────────────

class _CTAButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CTAButton(
      {required this.label, required this.color, required this.onTap});

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
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.95).animate(
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withValues(alpha: _pressing ? 0.2 : 0.4),
                blurRadius: _pressing ? 8 : 24,
                offset: Offset(0, _pressing ? 2 : 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
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
  const _OPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.bg,
    required this.accent,
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

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550))
      ..forward();
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.6, end: 1.0));
    _fade = CurvedAnimation(
            parent: _anim,
            curve: const Interval(0, 0.6, curve: Curves.easeOut))
        .drive(Tween(begin: 0.0, end: 1.0));
    _slide = CurvedAnimation(
            parent: _anim,
            curve: const Interval(0.1, 0.7, curve: Curves.easeOut))
        .drive(Tween(
            begin: const Offset(0, 0.15), end: Offset.zero));
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
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.page.accent.withValues(alpha: 0.12),
                border: Border.all(
                    color: widget.page.accent.withValues(alpha: 0.3),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: widget.page.accent.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 8)
                ],
              ),
              alignment: Alignment.center,
              child: Text(widget.page.emoji,
                  style: const TextStyle(fontSize: 68)),
            ),
          ),
          const SizedBox(height: 44),
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                children: [
                  Text(
                    widget.page.title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.page.body,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
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
