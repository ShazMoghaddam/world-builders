import 'dart:math';
import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';

/// Floating "+N bricks" burst shown on correct answer.
class BrickBurst extends StatefulWidget {
  final int bricks;
  final VoidCallback? onComplete;

  const BrickBurst({super.key, required this.bricks, this.onComplete});

  @override
  State<BrickBurst> createState() => _BrickBurstState();
}

class _BrickBurstState extends State<BrickBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rise;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rise = Tween(begin: 0.0, end: -80.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fade = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _rise.value),
        child: Opacity(
          opacity: _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: WBColors.brickOrange,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: WBColors.brickOrange.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '+${widget.bricks} 🧱',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Confetti particles — small coloured circles that scatter on correct answer.
class ConfettiParticles extends StatefulWidget {
  const ConfettiParticles({super.key});

  @override
  State<ConfettiParticles> createState() => _ConfettiParticlesState();
}

class _ConfettiParticlesState extends State<ConfettiParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      18,
      (_) => _Particle(
        x: _random.nextDouble() * 2 - 1,
        speedY: _random.nextDouble() * 0.6 + 0.4,
        speedX: (_random.nextDouble() - 0.5) * 0.8,
        color: [
          WBColors.mathAmber,
          WBColors.sciGreen,
          WBColors.litBlue,
          WBColors.lifePurple,
          WBColors.brickOrange,
        ][_random.nextInt(5)],
        size: _random.nextDouble() * 8 + 5,
        rotation: _random.nextDouble() * pi * 2,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: _particles.map((p) {
              final t = _controller.value;
              final dx = p.x * 100 + p.speedX * t * 80;
              final dy = -p.speedY * t * 140;
              final opacity = (1 - t * t).clamp(0.0, 1.0);
              return Positioned(
                left: 100 + dx,
                top: 100 + dy,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: p.rotation + t * pi,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: p.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x, speedY, speedX, size, rotation;
  final Color color;
  _Particle({
    required this.x,
    required this.speedY,
    required this.speedX,
    required this.color,
    required this.size,
    required this.rotation,
  });
}
