import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/widgets/wb_icons.dart';
import 'package:world_builders/core/services/audio_service.dart';
import 'package:world_builders/features/bingo/providers/bingo_state.dart';
import 'package:world_builders/features/bingo/widgets/bingo_cell_widget.dart';
import 'package:world_builders/features/bingo/widgets/bingo_celebration.dart';
import 'package:world_builders/providers/app_state.dart';

class BingoScreen extends StatefulWidget {
  const BingoScreen({super.key});
  @override
  State<BingoScreen> createState() => _BingoScreenState();
}

class _BingoScreenState extends State<BingoScreen> {
  bool _showCelebration = false;
  bool _celebrationShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BingoState>().loadOrGenerate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BingoState, AppState>(
      builder: (context, bingo, appState, _) {
        if (bingo.hasBingo && !_celebrationShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _showCelebration = true;
                _celebrationShown = true;
              });
              appState.addBricks(8, zoneId: 'bingo');
              context.read<AudioService>().playBingo();
            }
          });
        }

        return Scaffold(
          backgroundColor: WBColors.surface,
          body: SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: _BingoHeader(
                          completedCount: bingo.completedCount,
                          totalBricks: appState.bricks,
                          hasBingo: bingo.hasBingo,
                        ),
                      ),
                    ),

                    // Board label row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            Text("TODAY'S BOARD", style: WBTextStyles.label),
                            const Spacer(),
                            _DateBadge(),
                          ],
                        ),
                      ),
                    ),

                    // 5×5 Grid
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      sliver: SliverToBoxAdapter(
                        child: bingo.boardReady
                            ? _BingoGrid(bingo: bingo)
                            : const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      ),
                    ),

                    // Legend
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _CategoryLegend(),
                      ),
                    ),

                    // Progress
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        child: _ProgressSummary(bingo: bingo),
                      ),
                    ),
                  ],
                ),

                if (_showCelebration)
                  BingoCelebration(
                      onDismiss: () =>
                          setState(() => _showCelebration = false)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _BingoHeader extends StatelessWidget {
  final int completedCount;
  final int totalBricks;
  final bool hasBingo;
  const _BingoHeader(
      {required this.completedCount,
      required this.totalBricks,
      required this.hasBingo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Challenge', style: WBTextStyles.displayLarge),
                  const SizedBox(height: 4),
                  Text('Answer questions in Play to fill your board!',
                      style: WBTextStyles.body),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: WBColors.brickOrange,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: WBColors.brickOrange.withValues(alpha: 0.3),
                    blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  WBIcons.brick(color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text('$totalBricks',
                      style: WBText.body(14,
                          color: Colors.white, weight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatPill(
              label: '$completedCount / 25 done',
              color: WBColors.sciGreen,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(width: 8),
            _StatPill(
              label: hasBingo ? 'Challenge complete! 🎉' : 'Resets tomorrow',
              color: hasBingo ? WBColors.mathAmber : WBColors.lifePurple,
              icon: hasBingo ? Icons.star_rounded : Icons.today_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatPill(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: WBText.body(11, color: color, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Bingo grid ────────────────────────────────────────────────────────────────

class _BingoGrid extends StatelessWidget {
  final BingoState bingo;
  const _BingoGrid({required this.bingo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - 4 * 5) / 5;
        final gridHeight = cellSize * 5 + 4 * 5;
        return Column(
          children: [
            // Column headers — 5 subject icons
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: ['1', '2', '3', '4', '5'].map((col) {
                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: WBColors.lifePurple.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          col,
                          style: WBText.body(13,
                              color: WBColors.lifePurple,
                              weight: FontWeight.w900),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Grid sized to fit exactly — no internal scroll
            SizedBox(
              height: gridHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemCount: 25,
                itemBuilder: (context, index) {
                  final cell = bingo.board[index];
                  return BingoCellWidget(
                    cell: cell,
                    isInWinningLine: bingo.isCellInWinningLine(index),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Category legend ───────────────────────────────────────────────────────────

class _CategoryLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      ('Maths', WBColors.mathAmber),
      ('Literacy', WBColors.litBlue),
      ('Science', WBColors.sciGreen),
      ('Life Skills', WBColors.lifePurple),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                    color: item.$2, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(item.$1,
                  style: WBText.body(10,
                      color: WBColors.textSecondary,
                      weight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Date badge ────────────────────────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return Text(
      '${now.day} ${months[now.month - 1]}',
      style: WBTextStyles.label.copyWith(color: WBColors.lifePurple),
    );
  }
}

// ── Progress summary ──────────────────────────────────────────────────────────

class _ProgressSummary extends StatelessWidget {
  final BingoState bingo;
  const _ProgressSummary({required this.bingo});

  @override
  Widget build(BuildContext context) {
    final pct = ((bingo.completedCount / 25) * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WBColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WBColors.lifePurple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Board progress', style: WBTextStyles.titleMedium),
              Text('$pct%',
                  style: WBTextStyles.titleMedium
                      .copyWith(color: WBColors.lifePurple)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: bingo.completedCount / 25,
              minHeight: 10,
              backgroundColor: WBColors.lifePurple.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(WBColors.lifePurple),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            bingo.hasBingo
                ? '🎉 Challenge complete! Come back tomorrow for a new board.'
                : '${25 - bingo.completedCount} cells left — keep playing to complete the challenge!',
            style: WBTextStyles.label,
          ),
        ],
      ),
    );
  }
}
