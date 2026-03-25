import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';

/// Animated sky banner at the top of the Town screen.
/// Clouds drift slowly across the sky.
class TownSkyHeader extends StatefulWidget {
  final String childName;
  const TownSkyHeader({super.key, required this.childName});

  @override
  State<TownSkyHeader> createState() => _TownSkyHeaderState();
}

class _TownSkyHeaderState extends State<TownSkyHeader>
    with TickerProviderStateMixin {
  late AnimationController _cloud1;
  late AnimationController _cloud2;
  late AnimationController _sunPulse;

  @override
  void initState() {
    super.initState();
    _cloud1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _cloud2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();

    _sunPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloud1.dispose();
    _cloud2.dispose();
    _sunPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [WBColors.skyTop, WBColors.skyBottom],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sun
          Positioned(
            top: 24,
            right: 28,
            child: AnimatedBuilder(
              animation: _sunPulse,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + _sunPulse.value * 0.06,
                child: const _Sun(),
              ),
            ),
          ),
          // Cloud 1 (slower, larger)
          AnimatedBuilder(
            animation: _cloud1,
            builder: (_, __) {
              final x = -80 + _cloud1.value * (MediaQuery.of(context).size.width + 160);
              return Positioned(
                left: x,
                top: 30,
                child: const _Cloud(width: 90, opacity: 0.85),
              );
            },
          ),
          // Cloud 2 (faster, smaller)
          AnimatedBuilder(
            animation: _cloud2,
            builder: (_, __) {
              final x = -50 + _cloud2.value * (MediaQuery.of(context).size.width + 120);
              return Positioned(
                left: x,
                top: 60,
                child: const _Cloud(width: 60, opacity: 0.65),
              );
            },
          ),
          // Greeting text
          Positioned(
            bottom: 22,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.childName}! 👋',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your Town',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sun extends StatelessWidget {
  const _Sun();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFD700),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double opacity;
  const _Cloud({required this.width, required this.opacity});

  @override
  Widget build(BuildContext context) {
    final h = width * 0.4;
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        height: h + 16,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(h / 2),
                ),
              ),
            ),
            Positioned(
              bottom: h * 0.3,
              left: width * 0.15,
              child: Container(
                width: width * 0.45,
                height: width * 0.45 * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(width * 0.25),
                ),
              ),
            ),
            Positioned(
              bottom: h * 0.2,
              left: width * 0.42,
              child: Container(
                width: width * 0.3,
                height: width * 0.3 * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(width * 0.18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
