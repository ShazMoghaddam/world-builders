import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum ZoneType { numberDistrict, storyStreet, discoveryPark, lifeLane }

class ZoneInfo {
  final ZoneType type;
  final String id;
  final String name;
  final String emoji;
  final String tagline;
  final Color accentColor;
  final Color accentDark;
  final Color lightColor;
  final String townBuilding;

  const ZoneInfo({
    required this.type, required this.id, required this.name,
    required this.emoji, required this.tagline,
    required this.accentColor, required this.accentDark,
    required this.lightColor, required this.townBuilding,
  });

  static const List<ZoneInfo> all = [
    ZoneInfo(
      type: ZoneType.numberDistrict, id: 'number_district',
      name: 'Number District', emoji: '🔢', tagline: 'Maths adventures',
      accentColor: WBColors.mathAmber, accentDark: WBColors.mathAmberDark,
      lightColor: WBColors.mathAmberLight, townBuilding: 'School',
    ),
    ZoneInfo(
      type: ZoneType.storyStreet, id: 'story_street',
      name: 'Story Street', emoji: '📖', tagline: 'Reading & writing',
      accentColor: WBColors.litBlue, accentDark: WBColors.litBlueDark,
      lightColor: WBColors.litBlueLight, townBuilding: 'Library',
    ),
    ZoneInfo(
      type: ZoneType.discoveryPark, id: 'discovery_park',
      name: 'Discovery Park', emoji: '🔬', tagline: 'Science & nature',
      accentColor: WBColors.sciGreen, accentDark: WBColors.sciGreenDark,
      lightColor: WBColors.sciGreenLight, townBuilding: 'Lab',
    ),
    ZoneInfo(
      type: ZoneType.lifeLane, id: 'life_lane',
      name: 'Life Lane', emoji: '🌱', tagline: 'Real-world skills',
      accentColor: WBColors.lifePurple, accentDark: WBColors.lifePurpleDark,
      lightColor: WBColors.lifePurpleLight, townBuilding: 'Market',
    ),
  ];

  static ZoneInfo byId(String id) => all.firstWhere((z) => z.id == id);
}
