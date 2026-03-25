import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class QuestionRepository {
  final Map<String, List<Question>> _cache = {};
  // Tracks recently seen question IDs per zone
  final Map<String, List<String>> _recentlySeen = {};

  static const Map<String, String> _assetPaths = {
    'number_district': 'assets/questions/number_district.json',
    'story_street':    'assets/questions/story_street.json',
    'discovery_park':  'assets/questions/discovery_park.json',
    'life_lane':       'assets/questions/life_lane.json',
  };

  static const int _sessionSize   = 6;
  static const int _recentWindow  = 30; // larger pool now // don't repeat last 20 shown per zone

  Future<List<Question>> getQuestionsForZone(String zoneId) async {
    if (_cache.containsKey(zoneId)) return _cache[zoneId]!;
    final path = _assetPaths[zoneId];
    if (path == null) return [];
    try {
      final raw = await rootBundle.loadString(path);
      final list = json.decode(raw) as List;
      final questions = list
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache[zoneId] = questions;
      return questions;
    } catch (_) {
      return [];
    }
  }

  /// Returns a fresh session of questions, prioritising unseen ones.
  /// Seen IDs are persisted so they survive app restarts.
  Future<List<Question>> getSessionQuestions(String zoneId) async {
    final all = await getQuestionsForZone(zoneId);
    if (all.isEmpty) return [];

    // Load seen list from prefs
    final prefs = await SharedPreferences.getInstance();
    final seenKey = 'seen_$zoneId';
    final seen = Set<String>.from(prefs.getStringList(seenKey) ?? []);

    // Separate unseen and seen
    final unseen = all.where((q) => !seen.contains(q.id)).toList();
    final seenList = all.where((q) => seen.contains(q.id)).toList();

    // Shuffle both
    unseen.shuffle();
    seenList.shuffle();

    // Take up to _sessionSize from unseen first, fill rest from seen
    final pool = [...unseen, ...seenList];
    final session = pool.take(_sessionSize).toList();

    // Update seen list (rolling window of _recentWindow)
    final newSeen = {...seen, ...session.map((q) => q.id)}.toList();
    // If all questions have been seen, reset the window
    if (newSeen.length >= all.length) {
      // Keep only the last _sessionSize as "recently seen" to reset variety
      final resetSeen = session.map((q) => q.id).toList();
      await prefs.setStringList(seenKey, resetSeen);
    } else if (newSeen.length > _recentWindow) {
      // Trim to window size, keeping most recent
      await prefs.setStringList(seenKey, newSeen.skip(newSeen.length - _recentWindow).toList());
    } else {
      await prefs.setStringList(seenKey, newSeen);
    }

    return session;
  }

  Future<List<Question>> getQuestionsByTag(String tag) async {
    final all = <Question>[];
    for (final zoneId in _assetPaths.keys) {
      final questions = await getQuestionsForZone(zoneId);
      all.addAll(questions.where((q) => q.bingoTag == tag));
    }
    return all;
  }

  void clearCache() {
    _cache.clear();
    _recentlySeen.clear();
  }
}
