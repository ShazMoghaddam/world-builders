import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/widgets/wb_icons.dart';
import 'package:world_builders/core/widgets/wb_pressable.dart';
import 'package:world_builders/data/models/zone_info.dart';

class TownBuildingCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return WBPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: WBColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? zone.accentColor.withValues(alpha: 0.3)
                : WBColors.locked.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: zone.accentColor.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coloured top section
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? zone.accentColor.withValues(alpha: 0.13)
                    : WBColors.lockedBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Stack(
                children: [
                  // Centred icon
                  Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? zone.accentColor.withValues(alpha: 0.2)
                            : WBColors.locked.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isUnlocked
                            ? WBIcons.forZone(zone.id,
                                color: zone.accentColor, size: 28)
                            : WBIcons.lock(
                                color: WBColors.locked, size: 22),
                      ),
                    ),
                  ),
                  // Unlocked tick badge
                  if (isUnlocked)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: zone.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: WBText.body(13,
                        weight: FontWeight.w800,
                        color: isUnlocked
                            ? WBColors.textPrimary
                            : WBColors.locked),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUnlocked ? zone.tagline : 'Earn bricks to unlock',
                    style: WBText.body(11,
                        color: isUnlocked
                            ? zone.accentColor
                            : WBColors.locked,
                        weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: unlockProgress,
                              minHeight: 5,
                              backgroundColor:
                                  WBColors.locked.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation(
                                  zone.accentColor
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(unlockProgress * 10).round()}/10',
                          style: WBText.body(9,
                              color: WBColors.locked,
                              weight: FontWeight.w700),
                        ),
                      ],
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
