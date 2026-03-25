import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_builders/features/bingo/models/bingo_cell.dart';

class BingoState extends ChangeNotifier {
  static const int size = 5; // 5×5 board
  static const int freeIndex = 12; // centre cell

  List<BingoCell> _board = [];
  Set<int> _completedLines = {}; // indices of winning lines
  bool _hasBingo = false;
  String _boardDate = ''; // date string board was generated for

  // ── Getters ───────────────────────────────────────────────────
  List<BingoCell> get board => List.unmodifiable(_board);
  bool get hasBingo => _hasBingo;
  bool get boardReady => _board.isNotEmpty;
  int get completedCount => _board.where((c) => c.isCompleted).length;

  bool isCellInWinningLine(int index) {
    for (final line in _completedLines) {
      if (_lineIndices(line).contains(index)) return true;
    }
    return false;
  }

  // ── Board generation ──────────────────────────────────────────

  Future<void> loadOrGenerate() async {
    final today = _todayString();
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('bingo_date') ?? '';

    if (savedDate == today) {
      // Restore saved board
      final saved = prefs.getStringList('bingo_board');
      final completed = prefs.getStringList('bingo_completed') ?? [];
      if (saved != null && saved.length == size * size) {
        _boardDate = today;
        _board = saved.asMap().entries.map((e) {
          final cell = BingoCell.pool.firstWhere(
            (c) => c.id == e.value,
            orElse: () => BingoCell.pool.last,
          );
          return cell.copyWith(
            isCompleted: completed.contains(e.value) || cell.isFree,
          );
        }).toList();
        _checkAllLines();
        notifyListeners();
        return;
      }
    }

    // Generate fresh board for today
    _generateBoard(today);
    await _save();
    notifyListeners();
  }

  void _generateBoard(String dateKey) {
    _boardDate = dateKey;
    final rng = Random(dateKey.hashCode);

    // Pick 24 cells from pool (excluding free space) + 1 free
    final pool = BingoCell.pool.where((c) => !c.isFree).toList();
    pool.shuffle(rng);
    final picked = pool.take(24).toList();

    // Insert free space at centre (index 12)
    picked.insert(freeIndex, BingoCell.pool.firstWhere((c) => c.isFree));
    _board = picked;
    _completedLines = {};
    _hasBingo = false;
  }

  // ── Mark a cell complete ──────────────────────────────────────

  /// Called when a question with [tag] is answered correctly in Play.
  Future<void> markTag(String tag) async {
    if (tag.isEmpty) return;

    bool changed = false;
    for (int i = 0; i < _board.length; i++) {
      if (_board[i].tag == tag && !_board[i].isCompleted) {
        _board[i] = _board[i].copyWith(isCompleted: true);
        changed = true;
        break; // only mark one cell per correct answer
      }
    }

    if (changed) {
      _checkAllLines();
      await _save();
      notifyListeners();
    }
  }

  // ── Line detection ────────────────────────────────────────────

  void _checkAllLines() {
    _completedLines = {};

    // 5 rows
    for (int r = 0; r < size; r++) {
      final line = List.generate(size, (c) => r * size + c);
      if (_isLineComplete(line)) _completedLines.add(r);
    }
    // 5 columns
    for (int c = 0; c < size; c++) {
      final line = List.generate(size, (r) => r * size + c);
      if (_isLineComplete(line)) _completedLines.add(size + c);
    }
    // Diagonal top-left → bottom-right
    final diag1 = List.generate(size, (i) => i * size + i);
    if (_isLineComplete(diag1)) _completedLines.add(size * 2);
    // Diagonal top-right → bottom-left
    final diag2 = List.generate(size, (i) => i * size + (size - 1 - i));
    if (_isLineComplete(diag2)) _completedLines.add(size * 2 + 1);

    _hasBingo = _completedLines.isNotEmpty;
  }

  bool _isLineComplete(List<int> indices) =>
      indices.every((i) => _board[i].isCompleted);

  // Returns cell indices for a given line number
  List<int> _lineIndices(int lineNum) {
    if (lineNum < size) {
      // Row
      return List.generate(size, (c) => lineNum * size + c);
    } else if (lineNum < size * 2) {
      // Column
      final c = lineNum - size;
      return List.generate(size, (r) => r * size + c);
    } else if (lineNum == size * 2) {
      return List.generate(size, (i) => i * size + i);
    } else {
      return List.generate(size, (i) => i * size + (size - 1 - i));
    }
  }

  // ── Persistence ───────────────────────────────────────────────

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bingo_date', _boardDate);
    await prefs.setStringList('bingo_board', _board.map((c) => c.id).toList());
    await prefs.setStringList(
      'bingo_completed',
      _board.where((c) => c.isCompleted && !c.isFree).map((c) => c.id).toList(),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // Dev helper
  Future<void> resetBoard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bingo_date');
    await prefs.remove('bingo_board');
    await prefs.remove('bingo_completed');
    await loadOrGenerate();
  }
}
