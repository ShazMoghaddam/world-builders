import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';

class BingoCelebration extends StatefulWidget {
  final VoidCallback onDismiss;
  const BingoCelebration({super.key, required this.onDismiss});

  @override
  State<BingoCelebration> createState() => _BingoCelebrationState();
}

class _BingoCelebrationState extends State<BingoCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.3, end: 1.0));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: WBColors.cardWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: WBColors.sciGreen.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(
                      'BINGO!',
                      style: WBTextStyles.displayLarge.copyWith(
                        color: WBColors.sciGreen,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You completed a line!',
                      style: WBTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: WBColors.brickOrangeLight,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧱', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            '+8 bricks bonus!',
                            style: WBTextStyles.titleMedium
                                .copyWith(color: WBColors.brickOrange),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tap anywhere to continue',
                      style: WBTextStyles.label,
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
