import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/widgets/wb_icons.dart';
import 'package:world_builders/core/widgets/wb_pressable.dart';
import 'package:world_builders/data/models/zone_info.dart';
import 'package:world_builders/features/play/question_screen.dart';
import 'package:world_builders/main.dart';
import 'package:world_builders/providers/app_state.dart';
import 'package:world_builders/features/bingo/providers/bingo_state.dart';
import 'package:world_builders/features/play/providers/game_state.dart';
import 'widgets/town_building_card.dart';
import 'widgets/town_sky_header.dart';

class TownScreen extends StatelessWidget {
  const TownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, BingoState>(
      builder: (context, state, bingoState, _) {
        // Show unlock celebration if any new zones were just unlocked
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.newlyUnlocked.isNotEmpty) {
            final zoneId = state.newlyUnlocked.first;
            final zone = ZoneInfo.all.firstWhere((z) => z.id == zoneId);
            state.clearNewlyUnlocked();
            _showUnlockCelebration(context, zone);
          }
        });

        return Scaffold(
          backgroundColor: WBColors.surface,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: TownSkyHeader(childName: state.childName)),

                // Brick counter + streak row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      children: [
                        Expanded(child: _BrickBanner(bricks: state.bricks)),
                        if (state.streak > 0) ...[
                          const SizedBox(width: 10),
                          _StreakBadge(streak: state.streak),
                        ],
                      ],
                    ),
                  ),
                ),

                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: Text('YOUR TOWN', style: WBTextStyles.label),
                  ),
                ),

                // Building grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.crossAxisExtent > 600 ? 3 : 2;
                      final ratio = constraints.crossAxisExtent > 600 ? 0.9 : 1.0;
                      return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: ratio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final zone = ZoneInfo.all[index];
                        return TownBuildingCard(
                          zone: zone,
                          isUnlocked: state.isUnlocked(zone.id),
                          unlockProgress: state.unlockProgress(zone.id),
                          onTap: () => _onBuildingTap(context, zone, state),
                        );
                      },
                      childCount: ZoneInfo.all.length,
                    ),
                  );
                    }),
                ),

                // Daily bingo banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: _DailyChallengeBanner(
                      completedCount: bingoState.completedCount,
                      hasBingo: bingoState.hasBingo,
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

  void _showUnlockCelebration(BuildContext context, ZoneInfo zone) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => _UnlockCelebrationDialog(zone: zone),
    );
  }

  void _onBuildingTap(BuildContext context, ZoneInfo zone, AppState state) {
    if (state.isUnlocked(zone.id)) {
      _showZoneSheet(context, zone, unlocked: true);
    } else {
      _showZoneSheet(context, zone, unlocked: false);
    }
  }

  void _showZoneSheet(BuildContext context, ZoneInfo zone,
      {required bool unlocked}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ZoneSheet(zone: zone, unlocked: unlocked),
    );
  }
}

// ── Brick banner ──────────────────────────────────────────────────────────────

class _BrickBanner extends StatelessWidget {
  final int bricks;
  const _BrickBanner({required this.bricks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: WBColors.brickOrange,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: WBColors.brickOrange.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          WBIcons.brick(color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$bricks bricks',
                style: WBText.body(17,
                    color: Colors.white, weight: FontWeight.w800),
              ),
              Text(
                'Answer questions to earn more',
                style: WBText.body(11,
                    color: Colors.white.withValues(alpha: 0.75),
                    weight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Daily challenge banner ────────────────────────────────────────────────────

class _DailyChallengeBanner extends StatelessWidget {
  final int completedCount;
  final bool hasBingo;
  const _DailyChallengeBanner(
      {required this.completedCount, required this.hasBingo});

  @override
  Widget build(BuildContext context) {
    final remaining = 25 - completedCount;
    final subtitle = hasBingo
        ? 'You got Bingo today!'
        : '$remaining cell${remaining == 1 ? '' : 's'} left today';

    return WBPressable(
      onTap: () => appShellKey.currentState?.switchTab(2),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              WBColors.lifePurple,
              WBColors.lifePurpleDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WBColors.lifePurple.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: WBIcons.target(color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Bingo',
                      style: WBText.body(16,
                          color: Colors.white, weight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: WBText.body(12,
                          color: Colors.white.withValues(alpha: 0.8),
                          weight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text('Play',
                  style: WBText.body(13,
                      color: Colors.white, weight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zone bottom sheet ─────────────────────────────────────────────────────────

class _ZoneSheet extends StatelessWidget {
  final ZoneInfo zone;
  final bool unlocked;
  const _ZoneSheet({required this.zone, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1925),
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: zone.accentColor.withValues(alpha: 0.15),
                border: Border.all(
                    color: zone.accentColor.withValues(alpha: 0.3),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: zone.accentColor.withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 4)
                ],
              ),
              child: Center(
                child: unlocked
                    ? WBIcons.forZone(zone.id,
                        color: zone.accentColor, size: 38)
                    : WBIcons.lock(color: WBColors.locked, size: 32),
              ),
            ),
            const SizedBox(height: 18),
            Text(zone.name,
                style: WBText.body(22,
                    color: Colors.white, weight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              unlocked
                  ? zone.tagline
                  : 'Earn more bricks to unlock ${zone.name}.',
              style: WBText.body(14,
                  color: Colors.white.withValues(alpha: 0.5),
                  weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (unlocked)
              WBPressable(
                onTap: () async {
                  Navigator.pop(context);
                  final gameState = context.read<GameState>();
                  await gameState.startZone(zone.id);
                  if (context.mounted) {
                    appShellKey.currentState?.switchTab(1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => QuestionScreen(zone: zone)),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: zone.accentColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: zone.accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text("Let's Go! 🚀",
                      style: WBText.body(17,
                          color: Colors.white, weight: FontWeight.w800)),
                ),
              )
            else
              WBPressable(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  alignment: Alignment.center,
                  child: Text('Keep collecting bricks 🧱',
                      style: WBText.body(16,
                          color: Colors.white.withValues(alpha: 0.5),
                          weight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Streak badge ──────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: WBColors.sciGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: WBColors.sciGreen.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            '$streak',
            style: WBText.body(16, color: Colors.white, weight: FontWeight.w900),
          ),
          Text(
            'day${streak == 1 ? '' : 's'}',
            style: WBText.body(9, color: Colors.white.withValues(alpha: 0.8), weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Unlock celebration dialog ─────────────────────────────────────────────────

class _UnlockCelebrationDialog extends StatefulWidget {
  final ZoneInfo zone;
  const _UnlockCelebrationDialog({required this.zone});

  @override
  State<_UnlockCelebrationDialog> createState() =>
      _UnlockCelebrationDialogState();
}

class _UnlockCelebrationDialogState extends State<_UnlockCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.4, end: 1.0));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1925),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: widget.zone.accentColor.withValues(alpha: 0.4),
                  width: 2),
              boxShadow: [
                BoxShadow(
                  color: widget.zone.accentColor.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 4,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glow icon
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: widget.zone.accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: widget.zone.accentColor.withValues(alpha: 0.4),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.zone.accentColor.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: Center(
                    child: WBIcons.forZone(widget.zone.id,
                        color: widget.zone.accentColor, size: 40),
                  ),
                ),
                const SizedBox(height: 20),
                Text('🎉 Unlocked!',
                    style: WBText.body(14,
                        color: widget.zone.accentColor,
                        weight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  widget.zone.name,
                  style: WBText.body(26, color: Colors.white, weight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.zone.tagline,
                  style: WBText.body(14,
                      color: Colors.white.withValues(alpha: 0.55),
                      weight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                WBPressable(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: widget.zone.accentColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.zone.accentColor.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text("Let's explore! 🚀",
                        style: WBText.body(16,
                            color: Colors.white, weight: FontWeight.w800)),
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
