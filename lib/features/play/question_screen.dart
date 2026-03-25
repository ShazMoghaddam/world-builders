import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/services/audio_service.dart';
import 'package:world_builders/data/models/zone_info.dart';
import 'package:world_builders/features/bingo/providers/bingo_state.dart';
import 'package:world_builders/features/play/providers/game_state.dart';
import 'package:world_builders/features/play/widgets/answer_choice_button.dart';
import 'package:world_builders/features/play/widgets/brick_burst.dart';
import 'package:world_builders/features/play/widgets/wb_button.dart';
import 'package:world_builders/features/play/widgets/zone_complete_screen.dart';
import 'package:world_builders/providers/app_state.dart';

class QuestionScreen extends StatefulWidget {
  final ZoneInfo zone;
  const QuestionScreen({super.key, required this.zone});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {

  bool _showBurst = false;
  int  _burstBricks = 0;
  bool _showConfetti = false;

  // Card slide-in
  late AnimationController _cardCtrl;
  late Animation<Offset>   _cardSlide;
  late Animation<double>   _cardFade;

  // Feedback panel slide-up
  late AnimationController _feedbackCtrl;
  late Animation<Offset>   _feedbackSlide;

  // Hint flash overlay
  late AnimationController _hintCtrl;
  late Animation<double>   _hintOpacity;
  bool _hintTriggered = false;

  // Correct flash
  late AnimationController _flashCtrl;
  late Animation<double>   _flashOpacity;

  // Celebration scale
  late AnimationController _celebCtrl;
  late Animation<double>   _celebScale;

  // Screen shake
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeX;

  @override
  void initState() {
    super.initState();

    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _cardSlide = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: const Interval(0, 0.6)));
    _cardCtrl.forward();

    _feedbackCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _feedbackSlide = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _feedbackCtrl, curve: Curves.easeOutBack));

    // Hint: flash in fast, hold, fade out — total 1.4s
    _hintCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _hintOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12), // flash in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),           // hold
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 38), // fade out
    ]).animate(CurvedAnimation(parent: _hintCtrl, curve: Curves.easeInOut));

    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _flashOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.4), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.0), weight: 80),
    ]).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));

    _celebCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _celebScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.98), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _celebCtrl, curve: Curves.easeInOut));

    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeX = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 6.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _feedbackCtrl.dispose();
    _hintCtrl.dispose();
    _flashCtrl.dispose();
    _celebCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onAnswerTap(int index, GameState game, AppState appState,
      BingoState bingoState, AudioService audio) {
    final bricks = game.submitAnswer(index);

    if (game.isCorrect) {
      audio.playCorrect();
      appState.addBricks(bricks, zoneId: widget.zone.id);
      final tag = game.currentQuestion?.bingoTag ?? '';
      if (tag.isNotEmpty) {
        bingoState.markTag(tag);
        audio.playBrickCollect(); // satisfying "pop" when bingo cell fills
      }
      Future.delayed(const Duration(milliseconds: 400), () => audio.playBrickCollect());
      HapticFeedback.heavyImpact();
      _flashCtrl.forward(from: 0);
      _celebCtrl.forward(from: 0);
      setState(() { _showBurst = true; _burstBricks = bricks; _showConfetti = true; });
      _feedbackCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted || game.phase != GamePhase.correct) return;
        _onNext(game);
      });
    } else {
      audio.playWrong();
      HapticFeedback.mediumImpact();
      _shakeCtrl.forward(from: 0);
      _feedbackCtrl.forward(from: 0);
    }
  }

  void _onTryAgain(GameState game) {
    _feedbackCtrl.reverse().then((_) {
      if (!mounted) return;
      game.tryAgain();
      // After 2 retries — flash the hint overlay once
      if (game.shouldShowHint && !_hintTriggered) {
        _hintTriggered = true;
        _hintCtrl.forward(from: 0);
      } else if (game.shouldShowHint && _hintTriggered) {
        // Re-flash on every subsequent wrong attempt
        _hintCtrl.forward(from: 0);
      }
    });
  }

  void _onNext(GameState game) {
    setState(() { _showBurst = false; _showConfetti = false; });
    _hintTriggered = false;
    _feedbackCtrl.reverse().then((_) {
      if (!mounted) return;
      _hintCtrl.reset();
      _cardCtrl.forward(from: 0);
      game.nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<GameState, AppState, BingoState>(
      builder: (context, game, appState, bingoState, _) {
        final audio = context.read<AudioService>();

        if (game.phase == GamePhase.zoneComplete) {
          return ZoneCompleteScreen(
            zone: widget.zone,
            bricksEarned: game.sessionScore,
            correctCount: game.correctCount,
            totalCount: game.totalQuestions,
            onPlayAgain: () {
              _hintTriggered = false;
              for (final c in [_feedbackCtrl, _hintCtrl, _shakeCtrl, _flashCtrl, _celebCtrl]) c.reset();
              game.startZone(widget.zone.id);
            },
            onGoHome: () {
              game.reset();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          );
        }

        final question = game.currentQuestion;
        if (question == null) return const SizedBox();

        final isWrong   = game.phase == GamePhase.wrong;
        final isCorrect = game.phase == GamePhase.correct;

        return Scaffold(
          backgroundColor: WBColors.gameBg,
          body: Stack(
            children: [

              // Ambient glow
              Positioned(top: -100, left: -80,
                child: _GlowBlob(color: widget.zone.accentColor, size: 360)),

              // Main content — shakes on wrong
              AnimatedBuilder(
                animation: _shakeX,
                builder: (_, child) => Transform.translate(
                    offset: Offset(_shakeX.value, 0), child: child),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Top bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Row(children: [
                          WBIconButton(
                            bgColor: Colors.white.withValues(alpha: 0.08),
                            borderColor: Colors.white.withValues(alpha: 0.12),
                            onTap: () { game.reset(); Navigator.pop(context); },
                            child: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.7), size: 16),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: _StepDots(
                            total: game.totalQuestions,
                            current: game.questionIndex,
                            color: widget.zone.accentColor,
                          )),
                          const SizedBox(width: 14),
                          _BrickPill(bricks: appState.bricks),
                        ]),
                      ),

                      const SizedBox(height: 20),

                      // Zone label
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ZoneLabel(zone: widget.zone),
                      ),

                      const SizedBox(height: 14),

                      // Question card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SlideTransition(
                          position: _cardSlide,
                          child: FadeTransition(
                            opacity: _cardFade,
                            child: AnimatedBuilder(
                              animation: _celebScale,
                              builder: (_, child) => Transform.scale(
                                  scale: _celebScale.value, child: child),
                              child: _QuestionCard(
                                prompt: question.prompt,
                                num: game.questionIndex + 1,
                                total: game.totalQuestions,
                                color: widget.zone.accentColor,
                                isCorrect: isCorrect,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Answer choices — max width constrained for tablet
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: question.choices.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              AnswerState state = AnswerState.idle;
                              if (isCorrect) {
                                state = (i == question.answer)
                                    ? AnswerState.correct : AnswerState.dimmed;
                              }
                              if (isWrong) {
                                state = (i == game.selectedAnswer)
                                    ? AnswerState.wrong : AnswerState.dimmed;
                              }
                              final canTap = game.phase == GamePhase.question;
                              return AnswerChoiceButton(
                                text: question.choices[i],
                                index: i,
                                state: state,
                                onTap: canTap
                                    ? () => _onAnswerTap(i, game, appState, bingoState, audio)
                                    : null,
                              );
                            },
                          ),
                        ),
                          ),
                        ),
                      ),
                      SizedBox(height: 110 + MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),

              // ── Correct answer flash overlay ───────────────────────────────
              if (isCorrect)
                AnimatedBuilder(
                  animation: _flashOpacity,
                  builder: (_, __) => Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                          color: WBColors.correct.withValues(alpha: _flashOpacity.value)),
                    ),
                  ),
                ),

              // ── Hint flash overlay — centre of screen, auto-dismisses ──────
              AnimatedBuilder(
                animation: _hintOpacity,
                builder: (_, __) {
                  if (_hintOpacity.value == 0) return const SizedBox();
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.55 * _hintOpacity.value),
                        alignment: Alignment.center,
                        child: Opacity(
                          opacity: _hintOpacity.value,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1830),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: WBColors.hint.withValues(alpha: 0.5),
                                  width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: WBColors.hint.withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // HINT label
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: WBColors.hint.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: WBColors.hint.withValues(alpha: 0.4)),
                                  ),
                                  child: Text('HINT',
                                      style: WBText.body(11,
                                          color: WBColors.hint,
                                          weight: FontWeight.w800)),
                                ),
                                const SizedBox(height: 16),
                                // The correct answer — big and clear
                                Text(
                                  question.choices[question.answer],
                                  style: WBText.display(28, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Confetti
              if (_showConfetti)
                const Center(child: IgnorePointer(child: ConfettiParticles())),

              // Brick burst
              if (_showBurst)
                Positioned(
                  bottom: 220, left: 0, right: 0,
                  child: Center(
                    child: BrickBurst(
                      bricks: _burstBricks,
                      onComplete: () => setState(() => _showBurst = false),
                    ),
                  ),
                ),

              // Feedback panel
              if (isWrong || isCorrect)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: SlideTransition(
                    position: _feedbackSlide,
                    child: isCorrect
                        ? _CorrectPanel(
                            isLast: game.questionIndex >= game.totalQuestions - 1,
                            onNext: () => _onNext(game),
                            accentColor: widget.zone.accentColor,
                          )
                        : _WrongPanel(
                            retryCount: game.retryCount,
                            onTryAgain: () => _onTryAgain(game),
                          ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Glow blob ─────────────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1)),
  );
}



// ── Question card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final String prompt;
  final int num, total;
  final Color color;
  final bool isCorrect;
  const _QuestionCard({required this.prompt, required this.num,
      required this.total, required this.color, required this.isCorrect});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
    decoration: BoxDecoration(
      color: isCorrect ? WBColors.correct.withValues(alpha: 0.15) : WBColors.gameSurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isCorrect ? WBColors.correct.withValues(alpha: 0.5) : WBColors.gameBorder,
        width: isCorrect ? 1.5 : 1,
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Question $num of $total',
          style: WBText.body(11, color: color.withValues(alpha: 0.8), weight: FontWeight.w700)),
      const SizedBox(height: 10),
      Text(prompt, style: WBText.display(20, color: Colors.white, height: 1.35)),
    ]),
  );
}

// ── Step dots ─────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  final int total, current;
  final Color color;
  const _StepDots({required this.total, required this.current, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(total, (i) {
      final done = i < current; final active = i == current;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: active ? 24 : 8, height: 8,
        decoration: BoxDecoration(
          color: (done || active) ? color : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );
}

// ── Brick pill ────────────────────────────────────────────────────────────────

class _BrickPill extends StatelessWidget {
  final int bricks;
  const _BrickPill({required this.bricks});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: WBColors.brickOrange.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: WBColors.brickOrange.withValues(alpha: 0.35)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.view_module_rounded, color: WBColors.brickOrange, size: 14),
      const SizedBox(width: 6),
      Text('$bricks', style: WBText.body(14, color: WBColors.brickOrange, weight: FontWeight.w800)),
    ]),
  );
}

// ── Zone label ────────────────────────────────────────────────────────────────

class _ZoneLabel extends StatelessWidget {
  final ZoneInfo zone;
  const _ZoneLabel({required this.zone});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: zone.accentColor.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: zone.accentColor.withValues(alpha: 0.3)),
    ),
    child: Text(zone.name,
        style: WBText.body(12, color: zone.accentColor, weight: FontWeight.w700)),
  );
}

// ── Correct panel ─────────────────────────────────────────────────────────────

class _CorrectPanel extends StatefulWidget {
  final VoidCallback onNext;
  final bool isLast;
  final Color accentColor;
  const _CorrectPanel({required this.onNext, required this.isLast, required this.accentColor});

  @override
  State<_CorrectPanel> createState() => _CorrectPanelState();
}

class _CorrectPanelState extends State<_CorrectPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ic;
  late Animation<double> _is;

  @override
  void initState() {
    super.initState();
    _ic = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _is = CurvedAnimation(parent: _ic, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ic.forward();
  }

  @override
  void dispose() { _ic.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const green = WBColors.correct;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 38),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F0F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: green.withValues(alpha: 0.3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          ScaleTransition(
            scale: _is,
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: green, shape: BoxShape.circle),
              child: Center(child: Icon(Icons.star_rounded, color: Colors.white, size: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Brilliant!', style: WBText.display(22, color: green)),
            Text('Moving on in a moment…',
                style: WBText.body(13, color: Colors.white.withValues(alpha: 0.4))),
          ]),
        ]),
        const SizedBox(height: 18),
        WBButton(
          color: green,
          onTap: widget.onNext,
          shadows: [BoxShadow(color: green.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
          child: Text(widget.isLast ? 'See Results' : 'Next Question',
              style: WBText.display(17, color: Colors.white)),
        ),
      ]),
    );
  }
}

// ── Wrong panel ───────────────────────────────────────────────────────────────

class _WrongPanel extends StatefulWidget {
  final int retryCount;
  final VoidCallback onTryAgain;
  const _WrongPanel({required this.retryCount, required this.onTryAgain});

  @override
  State<_WrongPanel> createState() => _WrongPanelState();
}

class _WrongPanelState extends State<_WrongPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ic;
  late Animation<double> _is;

  @override
  void initState() {
    super.initState();
    _ic = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _is = CurvedAnimation(parent: _ic, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ic.forward();
  }

  @override
  void dispose() { _ic.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const red = WBColors.wrong;
    final sub = widget.retryCount >= 1
        ? 'Keep going — a hint is coming!'
        : 'Give it another go!';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 38),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0B0B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: red.withValues(alpha: 0.3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          ScaleTransition(
            scale: _is,
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
              child: Center(child: Icon(Icons.bolt_rounded, color: Colors.white, size: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Not quite!', style: WBText.display(22, color: red)),
            Text(sub, style: WBText.body(13, color: Colors.white.withValues(alpha: 0.4))),
          ])),
        ]),
        const SizedBox(height: 18),
        WBButton(
          color: red,
          onTap: widget.onTryAgain,
          shadows: [BoxShadow(color: red.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
          child: Text('Try Again', style: WBText.display(17, color: Colors.white)),
        ),
      ]),
    );
  }
}
