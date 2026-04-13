import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/widgets/wb_icons.dart';
import 'package:world_builders/core/widgets/wb_pressable.dart';
import 'package:world_builders/data/models/zone_info.dart';
import 'package:world_builders/providers/app_state.dart';
import 'package:world_builders/features/bingo/providers/bingo_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, BingoState>(
      builder: (context, appState, bingoState, _) {
        return Scaffold(
          backgroundColor: WBColors.surface,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeader(appState: appState),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _StatsRow(
                        appState: appState, bingoState: bingoState),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text('ZONE PROGRESS', style: WBTextStyles.label),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final zone = ZoneInfo.all[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ZoneProgressCard(
                            zone: zone,
                            bricksEarned: appState.bricksForZone(zone.id),
                            unlocked: appState.isUnlocked(zone.id),
                          ),
                        );
                      },
                      childCount: ZoneInfo.all.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text('ACHIEVEMENTS', style: WBTextStyles.label),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: _AchievementsGrid(
                        appState: appState, bingoState: bingoState),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    child: _ResetButton(
                        appState: appState, bingoState: bingoState),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AppState appState;
  const _ProfileHeader({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Row(
        children: [
          WBPressable(
            onTap: () => _showNameDialog(context, appState),
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: WBColors.lifePurple,
                shape: BoxShape.circle,
                border: Border.all(
                    color: WBColors.lifePurpleDark, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: WBColors.lifePurple.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  appState.avatar,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(appState.childName,
                        style: WBTextStyles.displayMedium),
                    const SizedBox(width: 8),
                    WBPressable(
                      onTap: () => _showNameDialog(context, appState),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: WBIcons.edit(
                            color: WBColors.textSecondary, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: WBColors.lifePurple,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    _rankLabel(appState.bricks),
                    style: WBText.body(11,
                        color: Colors.white, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _rankLabel(int bricks) {
    if (bricks >= 50) return '🏆 Master Builder';
    if (bricks >= 30) return '⭐ Expert Builder';
    if (bricks >= 15) return '🔨 Builder';
    return '🧱 Apprentice';
  }

  void _showNameDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: appState.childName);
    showDialog(
      context: context,
      builder: (_) => _EditProfileDialog(
        controller: controller,
        appState: appState,
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final AppState appState;
  final BingoState bingoState;
  const _StatsRow({required this.appState, required this.bingoState});

  @override
  Widget build(BuildContext context) {
    final unlockedCount =
        ZoneInfo.all.where((z) => appState.isUnlocked(z.id)).length;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: WBIcons.brick(color: Colors.white, size: 20),
                value: '${appState.bricks}',
                label: 'Bricks',
                color: WBColors.brickOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: WBIcons.town(color: Colors.white, size: 20),
                value: '$unlockedCount / ${ZoneInfo.all.length}',
                label: 'Zones',
                color: WBColors.lifePurple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: WBIcons.target(color: Colors.white, size: 20),
                value: '${bingoState.completedCount}',
                label: 'Challenge',
                color: WBColors.sciGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Widget icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 8),
          Text(value,
              style: WBText.body(18,
                  color: Colors.white, weight: FontWeight.w800)),
          Text(label,
              style: WBText.body(11,
                  color: Colors.white.withValues(alpha: 0.8),
                  weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Zone progress card ────────────────────────────────────────────────────────

class _ZoneProgressCard extends StatelessWidget {
  final ZoneInfo zone;
  final int bricksEarned;
  final bool unlocked;

  const _ZoneProgressCard({
    required this.zone,
    required this.bricksEarned,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WBColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? zone.accentColor.withValues(alpha: 0.25)
              : WBColors.locked.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: unlocked
                  ? zone.accentColor.withValues(alpha: 0.12)
                  : WBColors.lockedBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: unlocked
                  ? WBIcons.forZone(zone.id,
                      color: zone.accentColor, size: 22)
                  : WBIcons.lock(color: WBColors.locked, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(zone.name,
                        style: WBTextStyles.titleMedium.copyWith(
                            color: unlocked
                                ? WBColors.textPrimary
                                : WBColors.locked)),
                    Row(
                      children: [
                        WBIcons.brick(
                            color: unlocked
                                ? WBColors.brickOrange
                                : WBColors.locked,
                            size: 12),
                        const SizedBox(width: 4),
                        Text('$bricksEarned',
                            style: WBTextStyles.label.copyWith(
                                color: unlocked
                                    ? WBColors.brickOrange
                                    : WBColors.locked)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: unlocked
                        ? (bricksEarned / 10).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 6,
                    backgroundColor:
                        zone.accentColor.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation(zone.accentColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked
                      ? '$bricksEarned bricks earned here'
                      : 'Not yet unlocked',
                  style: WBTextStyles.label.copyWith(
                    color: unlocked
                        ? WBColors.textSecondary
                        : WBColors.locked,
                    fontSize: 10,
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

// ── Achievements grid ─────────────────────────────────────────────────────────

class _AchievementsGrid extends StatelessWidget {
  final AppState appState;
  final BingoState bingoState;
  const _AchievementsGrid(
      {required this.appState, required this.bingoState});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _Achievement(emoji: '🧱', label: 'First Brick',
          desc: 'Earn your first brick', unlocked: appState.bricks >= 1),
      _Achievement(emoji: '🔟', label: 'Ten Bricks',
          desc: 'Collect 10 bricks', unlocked: appState.bricks >= 10),
      _Achievement(emoji: '🏙️', label: 'Town Starter',
          desc: 'Unlock a second zone',
          unlocked: ZoneInfo.all
                  .where((z) => appState.isUnlocked(z.id))
                  .length >= 2),
      _Achievement(emoji: '🌟', label: 'All Zones',
          desc: 'Unlock all 4 zones',
          unlocked: ZoneInfo.all.every((z) => appState.isUnlocked(z.id))),
      _Achievement(emoji: '🎯', label: 'Challenge!',
          desc: 'Complete a challenge line', unlocked: bingoState.hasBingo),
      _Achievement(emoji: '🏆', label: 'Master Builder',
          desc: 'Earn 50 bricks', unlocked: appState.bricks >= 50),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) =>
          _AchievementBadge(achievement: achievements[index]),
    );
  }
}

class _Achievement {
  final String emoji, label, desc;
  final bool unlocked;
  const _Achievement(
      {required this.emoji,
      required this.label,
      required this.desc,
      required this.unlocked});
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? WBColors.mathAmberLight : WBColors.lockedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? WBColors.mathAmber.withValues(alpha: 0.35)
              : WBColors.locked.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            unlocked ? achievement.emoji : '🔒',
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(achievement.label,
              style: WBTextStyles.label.copyWith(
                  color: unlocked
                      ? WBColors.textPrimary
                      : WBColors.locked,
                  fontSize: 10),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(achievement.desc,
              style: WBTextStyles.label.copyWith(
                  color: unlocked
                      ? WBColors.textSecondary
                      : WBColors.locked.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Reset button ──────────────────────────────────────────────────────────────

class _ResetButton extends StatelessWidget {
  final AppState appState;
  final BingoState bingoState;
  const _ResetButton({required this.appState, required this.bingoState});

  @override
  Widget build(BuildContext context) {
    return WBPressable(
      onTap: () => _confirmReset(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: WBColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: WBColors.locked.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WBIcons.refresh(color: WBColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            Text('Reset all progress',
                style:
                    WBTextStyles.label.copyWith(color: WBColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Reset everything?',
            style: WBTextStyles.titleLarge),
        content: Text(
            'This will clear all bricks, unlocked zones, and challenge progress. Are you sure?',
            style: WBTextStyles.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WBColors.brickOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await appState.reset();
              await bingoState.resetBoard();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}



// ── Edit profile dialog ───────────────────────────────────────────────────────

class _EditProfileDialog extends StatefulWidget {
  final TextEditingController controller;
  final AppState appState;
  const _EditProfileDialog(
      {required this.controller, required this.appState});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late String _selectedAvatar;

  static const _avatars = [
    '🦁', '🐯', '🦊', '🐻', '🐼', '🐨', '🐸', '🐧',
    '🦄', '🐉', '🦋', '🐬', '🦅', '🐺', '🦝', '🦓',
    '🐙', '🦈', '🐮', '🐷', '🦜', '🐢', '🐳', '🦒',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.appState.avatar;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Edit Profile', style: WBTextStyles.titleLarge),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.controller,
              autofocus: true,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Your name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: WBColors.lifePurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Choose your avatar',
                style: WBText.body(13,
                    color: WBColors.textSecondary,
                    weight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _avatars.map((emoji) {
                final selected = emoji == _selectedAvatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = emoji),
                  child: AnimatedContainer(
                    width: 48,
                    height: 48,
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selected
                          ? WBColors.lifePurpleLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? WBColors.lifePurple
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: TextStyle(fontSize: selected ? 22 : 18)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: WBColors.lifePurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final name = widget.controller.text.trim();
            if (name.isNotEmpty) widget.appState.setChildName(name);
            widget.appState.setAvatar(_selectedAvatar);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
