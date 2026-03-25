import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/zone_info.dart';

class AppState extends ChangeNotifier {
  int _bricks = 0;
  String _childName = 'Builder';
  String _avatar = '🧱';
  final Set<String> _unlockedZones = {'number_district'};
  final Map<String, int> _zoneBricks = {};
  int _streak = 0;
  String _lastPlayedDate = '';
  final Set<String> _newlyUnlocked = {}; // zones unlocked this session

  int get bricks => _bricks;
  String get childName => _childName;
  String get avatar => _avatar;
  Set<String> get unlockedZones => Set.unmodifiable(_unlockedZones);
  int get streak => _streak;
  Set<String> get newlyUnlocked => Set.unmodifiable(_newlyUnlocked);

  bool isUnlocked(String zoneId) => _unlockedZones.contains(zoneId);
  int bricksForZone(String zoneId) => _zoneBricks[zoneId] ?? 0;

  double unlockProgress(String zoneId) {
    if (isUnlocked(zoneId)) return 1.0;
    final idx = ZoneInfo.all.indexWhere((z) => z.id == zoneId);
    if (idx < 0) return 0.0;
    final threshold = _unlockThresholds[idx];
    if (threshold == 0) return 1.0;
    return (_bricks / threshold).clamp(0.0, 1.0);
  }

  void addBricks(int amount, {required String zoneId}) {
    _bricks += amount;
    if (ZoneInfo.all.any((z) => z.id == zoneId)) {
      _zoneBricks[zoneId] = (_zoneBricks[zoneId] ?? 0) + amount;
    }
    _checkUnlock();
    _updateStreak();
    _save();
    notifyListeners();
  }

  void setChildName(String name) {
    _childName = name;
    _save();
    notifyListeners();
  }

  void setAvatar(String avatar) {
    _avatar = avatar;
    _save();
    notifyListeners();
  }

  void clearNewlyUnlocked() {
    _newlyUnlocked.clear();
    notifyListeners();
  }

  // Unlock thresholds — spread out so earning each zone feels rewarding
  static const _unlockThresholds = [0, 15, 35, 60];

  void _checkUnlock() {
    final order = ZoneInfo.all.map((z) => z.id).toList();
    for (int i = 0; i < order.length; i++) {
      final id = order[i];
      if (!_unlockedZones.contains(id)) {
        final threshold = _unlockThresholds[i];
        if (_bricks >= threshold) {
          _unlockedZones.add(id);
          _newlyUnlocked.add(id);
        }
      }
    }
  }

  void _updateStreak() {
    final today = _todayString();
    if (_lastPlayedDate == today) return; // already played today

    final yesterday = _yesterdayString();
    if (_lastPlayedDate == yesterday) {
      _streak++; // consecutive day
    } else if (_lastPlayedDate != today) {
      _streak = 1; // reset streak (gap in play)
    }
    _lastPlayedDate = today;
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _bricks = prefs.getInt('bricks') ?? 0;
    _childName = prefs.getString('childName') ?? 'Builder';
    _avatar = prefs.getString('avatar') ?? '🧱';
    _streak = prefs.getInt('streak') ?? 0;
    _lastPlayedDate = prefs.getString('lastPlayedDate') ?? '';
    final unlocked = prefs.getStringList('unlockedZones');
    if (unlocked != null) _unlockedZones.addAll(unlocked);
    for (final zone in ZoneInfo.all) {
      _zoneBricks[zone.id] = prefs.getInt('zoneBricks_${zone.id}') ?? 0;
    }
    // Check if streak should reset (hasn't played since yesterday or before)
    final today = _todayString();
    final yesterday = _yesterdayString();
    if (_lastPlayedDate != today && _lastPlayedDate != yesterday && _lastPlayedDate.isNotEmpty) {
      _streak = 0;
      await prefs.setInt('streak', 0);
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bricks', _bricks);
    await prefs.setString('childName', _childName);
    await prefs.setString('avatar', _avatar);
    await prefs.setInt('streak', _streak);
    await prefs.setString('lastPlayedDate', _lastPlayedDate);
    await prefs.setStringList('unlockedZones', _unlockedZones.toList());
    for (final entry in _zoneBricks.entries) {
      await prefs.setInt('zoneBricks_${entry.key}', entry.value);
    }
  }

  Future<void> reset() async {
    _bricks = 0;
    _childName = 'Builder';
    _avatar = '🧱';
    _streak = 0;
    _lastPlayedDate = '';
    _unlockedZones
      ..clear()
      ..add('number_district');
    _zoneBricks.clear();
    _newlyUnlocked.clear();
    await _save();
    notifyListeners();
  }
}
