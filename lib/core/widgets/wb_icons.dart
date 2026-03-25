import 'package:flutter/material.dart';

/// App icon library — uses Flutter Material Icons for cross-platform reliability.
/// Usage: WBIcons.math(color: WBColors.mathAmber, size: 24)
class WBIcons {
  WBIcons._();

  static Widget town({required Color color, double size = 24}) =>
      Icon(Icons.location_city_rounded, color: color, size: size);

  static Widget play({required Color color, double size = 24}) =>
      Icon(Icons.sports_esports_rounded, color: color, size: size);

  static Widget bingo({required Color color, double size = 24}) =>
      Icon(Icons.grid_view_rounded, color: color, size: size);

  static Widget profile({required Color color, double size = 24}) =>
      Icon(Icons.person_rounded, color: color, size: size);

  static Widget brick({required Color color, double size = 24}) =>
      Icon(Icons.view_module_rounded, color: color, size: size);

  static Widget lock({required Color color, double size = 24}) =>
      Icon(Icons.lock_rounded, color: color, size: size);

  static Widget star({required Color color, double size = 24}) =>
      Icon(Icons.star_rounded, color: color, size: size);

  static Widget check({required Color color, double size = 24}) =>
      Icon(Icons.check_rounded, color: color, size: size);

  static Widget zap({required Color color, double size = 24}) =>
      Icon(Icons.bolt_rounded, color: color, size: size);

  static Widget close({required Color color, double size = 24}) =>
      Icon(Icons.close_rounded, color: color, size: size);

  static Widget edit({required Color color, double size = 24}) =>
      Icon(Icons.edit_outlined, color: color, size: size);

  static Widget target({required Color color, double size = 24}) =>
      Icon(Icons.my_location_rounded, color: color, size: size);

  static Widget math({required Color color, double size = 24}) =>
      Icon(Icons.calculate_rounded, color: color, size: size);

  static Widget book({required Color color, double size = 24}) =>
      Icon(Icons.menu_book_rounded, color: color, size: size);

  static Widget science({required Color color, double size = 24}) =>
      Icon(Icons.science_rounded, color: color, size: size);

  static Widget life({required Color color, double size = 24}) =>
      Icon(Icons.favorite_rounded, color: color, size: size);

  static Widget trophy({required Color color, double size = 24}) =>
      Icon(Icons.emoji_events_rounded, color: color, size: size);

  static Widget arrowRight({required Color color, double size = 24}) =>
      Icon(Icons.arrow_forward_ios_rounded, color: color, size: size);

  static Widget refresh({required Color color, double size = 24}) =>
      Icon(Icons.refresh_rounded, color: color, size: size);

  /// Returns the zone icon for a given zone ID
  static Widget forZone(String zoneId,
      {required Color color, double size = 24}) {
    switch (zoneId) {
      case 'number_district':
        return math(color: color, size: size);
      case 'story_street':
        return book(color: color, size: size);
      case 'discovery_park':
        return science(color: color, size: size);
      case 'life_lane':
        return life(color: color, size: size);
      default:
        return star(color: color, size: size);
    }
  }
}
