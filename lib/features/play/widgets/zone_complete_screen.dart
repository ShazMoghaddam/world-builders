import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/data/models/zone_info.dart';

class ZoneCompleteScreen extends StatefulWidget {
  final ZoneInfo zone;
  final int bricksEarned;
  final int correctCount;
  final int totalCount;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const ZoneCompleteScreen({
    super.key,
    required this.zone,
    required this.bricksEarned,
    required this.correctCount,
    required this.totalCount,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  State<ZoneCompleteScreen> createState() => _ZoneCompleteScreenState();
}

class _ZoneCompleteScreenState extends State<ZoneCompleteScreen>
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
        .drive(Tween(begin: 0.5, end: 1.0));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _medal {
    final pct = widget.correctCount / widget.totalCount;
    if (pct == 1.0) return '🥇';
    if (pct >= 0.6) return '🥈';
    return '🥉';
  }

  String get _message {
    final pct = widget.correctCount / widget.totalCount;
    if (pct == 1.0) return 'Perfect score! Amazing!';
    if (pct >= 0.8) return 'Brilliant work!';
    if (pct >= 0.6) return 'Great effort!';
    return 'Keep practising!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.zone.lightColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Medal
                ScaleTransition(
                  scale: _scale,
                  child: Text(_medal,
                      style: const TextStyle(fontSize: 80)),
                ),
                const SizedBox(height: 16),
                Text(
                  _message,
                  style: WBTextStyles.displayMedium
                      .copyWith(color: widget.zone.accentColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.zone.name} complete!',
                  style: WBTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        emoji: '✅',
                        value: '${widget.correctCount}/${widget.totalCount}',
                        label: 'Correct',
                        color: widget.zone.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        emoji: '🧱',
                        value: '+${widget.bricksEarned}',
                        label: 'Bricks earned',
                        color: WBColors.brickOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.zone.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: WBTextStyles.titleMedium,
                    ),
                    onPressed: widget.onPlayAgain,
                    child: const Text('Play again 🔄'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onGoHome,
                  child: Text(
                    'Back to Town',
                    style: WBTextStyles.body
                        .copyWith(color: widget.zone.accentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WBColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: WBTextStyles.displayMedium.copyWith(color: color),
          ),
          Text(label, style: WBTextStyles.label),
        ],
      ),
    );
  }
}
