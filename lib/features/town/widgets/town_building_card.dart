import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/widgets/wb_icons.dart';
import 'package:world_builders/core/widgets/wb_pressable.dart';
import 'package:world_builders/data/models/zone_info.dart';

class TownBuildingCard extends StatefulWidget {
  final ZoneInfo zone;
  final bool isUnlocked;
  final double unlockProgress;
  final VoidCallback onTap;

  const TownBuildingCard({
    super.key,
    required this.zone,
    required this.isUnlocked,
    required this.unlockProgress,
    required this.onTap,
  });

  @override
  State<TownBuildingCard> createState() => _TownBuildingCardState();
}

class _TownBuildingCardState extends State<TownBuildingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _badgeScale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    if (widget.isUnlocked) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(TownBuildingCard old) {
    super.didUpdateWidget(old);
    if (widget.isUnlocked && !old.isUnlocked) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    final unlocked = widget.isUnlocked;
    final accent = zone.accentColor;
    final gradient = WBGradients.forZone(zone.id);

    return WBPressable(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: WBColors.cardWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: unlocked
                ? accent.withValues(alpha: 0.25)
                : WBColors.locked.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: unlocked
              ? WBShadows.card(color: accent)
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Coloured top section ────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(21)),
              child: Container(
                height: 108,
                decoration: BoxDecoration(
                  gradient: unlocked
                      ? LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.18),
                            accent.withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFEFEDF8), Color(0xFFE8E5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: Stack(
                  children: [
                    // Decorative circle (background texture)
                    Positioned(
                      right: -18,
                      top: -18,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: unlocked
                              ? accent.withValues(alpha: 0.07)
                              : WBColors.locked.withValues(alpha: 0.05),
                        ),
                      ),
                    ),

                    // Centred icon circle
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: unlocked
                              ? LinearGradient(
                                  colors: [
                                    accent.withValues(alpha: 0.28),
                                    accent.withValues(alpha: 0.14),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: unlocked
                              ? null
                              : WBColors.locked.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          boxShadow: unlocked
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.20),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: unlocked
                              ? WBIcons.forZone(zone.id,
                                  color: accent, size: 28)
                              : WBIcons.lock(
                                  color: WBColors.locked, size: 22),
                        ),
                      ),
                    ),

                    // Unlocked badge (animated)
                    if (unlocked)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ScaleTransition(
                          scale: _badgeScale,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              shape: BoxShape.circle,
                              boxShadow: WBShadows.pill(accent),
                            ),
                            child: const Center(
                              child: Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ),

                    // Progress chip for locked
                    if (!unlocked)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: WBColors.locked.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(widget.unlockProgress * 10).round()}/10',
                            style: WBText.body(9,
                                color: WBColors.locked,
                                weight: FontWeight.w800),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Bottom info ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: WBText.body(13,
                        weight: FontWeight.w800,
                        color: unlocked
                            ? WBColors.textPrimary
                            : WBColors.locked),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    unlocked ? zone.tagline : 'Earn bricks to unlock',
                    style: WBText.body(11,
                        color: unlocked ? accent : WBColors.locked,
                        weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progress bar for locked cards
                  if (!unlocked) ...[
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: widget.unlockProgress,
                        minHeight: 5,
                        backgroundColor:
                            WBColors.locked.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(
                            accent.withValues(alpha: 0.5)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
