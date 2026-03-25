import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/widgets/wb_icons.dart';
import 'package:world_builders/core/widgets/wb_pressable.dart';
import 'package:world_builders/data/models/zone_info.dart';
import 'package:world_builders/features/play/providers/game_state.dart';
import 'package:world_builders/features/play/question_screen.dart';
import 'package:world_builders/providers/app_state.dart';

class PlayScreen extends StatefulWidget {
  final ZoneInfo? initialZone;
  const PlayScreen({super.key, this.initialZone});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialZone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchZone(widget.initialZone!);
      });
    }
  }

  void _launchZone(ZoneInfo zone) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => QuestionScreen(zone: zone)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          backgroundColor: WBColors.surface,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Play', style: WBTextStyles.displayLarge),
                        const SizedBox(height: 4),
                        Text('Pick a zone and start learning!',
                            style: WBTextStyles.body),
                      ],
                    ),
                  ),
                ),

                // Brick summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _BrickSummary(bricks: appState.bricks),
                  ),
                ),

                // Section label
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Text('CHOOSE A ZONE', style: WBTextStyles.label),
                  ),
                ),

                // Zone list — max-width constrained for tablet
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                        child: Column(
                          children: ZoneInfo.all.map((zone) {
                            final unlocked = appState.isUnlocked(zone.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ZonePlayCard(
                                zone: zone,
                                unlocked: unlocked,
                                bricksEarned: appState.bricksForZone(zone.id),
                                onTap: unlocked
                                    ? () => _startZone(context, zone)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startZone(BuildContext context, ZoneInfo zone) async {
    final gameState = context.read<GameState>();
    await gameState.startZone(zone.id);
    if (!context.mounted) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => QuestionScreen(zone: zone)));
  }
}

// ── Brick summary ─────────────────────────────────────────────────────────────

class _BrickSummary extends StatelessWidget {
  final int bricks;
  const _BrickSummary({required this.bricks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: WBColors.brickOrange,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: WBColors.brickOrange.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          WBIcons.brick(color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$bricks bricks collected',
                  style: WBText.body(15,
                      color: Colors.white, weight: FontWeight.w800)),
              Text('Answer questions to earn more!',
                  style: WBText.body(11,
                      color: Colors.white.withValues(alpha: 0.75),
                      weight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Zone play card ────────────────────────────────────────────────────────────

class _ZonePlayCard extends StatelessWidget {
  final ZoneInfo zone;
  final bool unlocked;
  final int bricksEarned;
  final VoidCallback? onTap;

  const _ZonePlayCard({
    required this.zone,
    required this.unlocked,
    required this.bricksEarned,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WBPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked
              ? zone.accentColor.withValues(alpha: 0.08)
              : WBColors.lockedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked
                ? zone.accentColor.withValues(alpha: 0.3)
                : WBColors.locked.withValues(alpha: 0.15),
            width: unlocked ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: unlocked
                    ? zone.accentColor.withValues(alpha: 0.15)
                    : WBColors.locked.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: unlocked
                    ? WBIcons.forZone(zone.id,
                        color: zone.accentColor, size: 26)
                    : WBIcons.lock(color: WBColors.locked, size: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: WBText.body(15,
                        weight: FontWeight.w800,
                        color: unlocked
                            ? WBColors.textPrimary
                            : WBColors.locked),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unlocked ? zone.tagline : 'Earn 10 bricks to unlock',
                    style: WBText.body(12,
                        color: unlocked ? zone.accentColor : WBColors.locked,
                        weight: FontWeight.w600),
                  ),
                  if (unlocked && bricksEarned > 0) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        WBIcons.brick(
                            color: WBColors.brickOrange, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '$bricksEarned earned here',
                          style: WBText.body(11,
                              color: WBColors.brickOrange,
                              weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (unlocked)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: zone.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                      WBIcons.arrowRight(color: Colors.white, size: 18),
                ),
              )
            else
              WBIcons.lock(color: WBColors.locked, size: 20),
          ],
        ),
      ),
    );
  }
}
