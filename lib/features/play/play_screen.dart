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
                // ── Header ─────────────────────────────────────
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

                // ── Brick summary ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _BrickSummary(bricks: appState.bricks),
                  ),
                ),

                // ── Section label ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Text('CHOOSE A ZONE', style: WBTextStyles.label),
                  ),
                ),

                // ── Zone list ───────────────────────────────────
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
                                bricksEarned:
                                    appState.bricksForZone(zone.id),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: WBGradients.brickWarm,
        borderRadius: BorderRadius.circular(20),
        boxShadow: WBShadows.button(WBColors.brickOrange),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: WBIcons.brick(color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$bricks bricks collected',
                    style: WBText.body(15,
                        color: Colors.white, weight: FontWeight.w800)),
                const SizedBox(height: 1),
                Text('Answer questions to earn more!',
                    style: WBText.body(11,
                        color: Colors.white.withValues(alpha: 0.75),
                        weight: FontWeight.w600)),
              ],
            ),
          ),
          // Mini progress visual
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '🏆',
                style: const TextStyle(fontSize: 22),
              ),
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
    final accent = zone.accentColor;

    return WBPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: WBColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked
                ? accent.withValues(alpha: 0.20)
                : WBColors.locked.withValues(alpha: 0.12),
            width: 1.5,
          ),
          boxShadow: unlocked
              ? WBShadows.card(color: accent, elevation: 0.7)
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // ── Accent stripe ───────────────────────────
            Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: unlocked
                    ? WBGradients.forZone(zone.id)
                    : const LinearGradient(
                        colors: [Color(0xFFD0CCEE), Color(0xFFB8B5CC)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20)),
              ),
            ),

            // ── Content ─────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Icon bubble
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? accent.withValues(alpha: 0.12)
                            : WBColors.locked.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: unlocked
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: unlocked
                            ? WBIcons.forZone(zone.id, color: accent, size: 26)
                            : WBIcons.lock(color: WBColors.locked, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            zone.name,
                            style: WBText.body(15,
                                weight: FontWeight.w800,
                                color: unlocked
                                    ? WBColors.textPrimary
                                    : WBColors.locked),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            unlocked
                                ? zone.tagline
                                : 'Earn 10 bricks to unlock',
                            style: WBText.body(12,
                                color: unlocked ? accent : WBColors.locked,
                                weight: FontWeight.w600),
                          ),
                          if (unlocked && bricksEarned > 0) ...[
                            const SizedBox(height: 6),
                            _BrickChip(bricks: bricksEarned),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Arrow / lock
                    if (unlocked)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: WBGradients.forZone(zone.id),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: WBShadows.pill(accent),
                        ),
                        child: Center(
                          child: WBIcons.arrowRight(
                              color: Colors.white, size: 18),
                        ),
                      )
                    else
                      WBIcons.lock(color: WBColors.locked, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrickChip extends StatelessWidget {
  final int bricks;
  const _BrickChip({required this.bricks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: WBColors.brickOrangeLight,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: WBColors.brickOrange.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WBIcons.brick(color: WBColors.brickOrange, size: 11),
          const SizedBox(width: 4),
          Text(
            '$bricks earned here',
            style: WBText.body(10,
                color: WBColors.brickOrange,
                weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
