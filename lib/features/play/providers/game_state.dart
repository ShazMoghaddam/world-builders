import 'package:flutter/foundation.dart';
import 'package:world_builders/data/models/question.dart';
import 'package:world_builders/data/repositories/question_repository.dart';

enum GamePhase { idle, loading, question, correct, wrong, zoneComplete }

class GameState extends ChangeNotifier {
  final QuestionRepository _repo;
  GameState(this._repo);

  GamePhase _phase = GamePhase.idle;
  String? _activeZoneId;
  List<Question> _questions = [];
  int _questionIndex = 0;
  int _sessionScore = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _retryCount = 0;
  final Set<int> _triedWrongAnswers = {};

  GamePhase get phase => _phase;
  String? get activeZoneId => _activeZoneId;
  int get sessionScore => _sessionScore;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  int? get selectedAnswer => _selectedAnswer;
  bool get answered => _answered;
  int get retryCount => _retryCount;
  bool get shouldShowHint => _retryCount >= 2;

  int? get hintEliminateIndex {
    if (!shouldShowHint || currentQuestion == null) return null;
    final q = currentQuestion!;
    for (int i = 0; i < q.choices.length; i++) {
      if (i != q.answer && !_triedWrongAnswers.contains(i)) return i;
    }
    return null;
  }

  Question? get currentQuestion =>
      _questions.isNotEmpty && _questionIndex < _questions.length
          ? _questions[_questionIndex] : null;

  int get totalQuestions => _questions.length;
  int get questionIndex => _questionIndex;

  bool get isCorrect =>
      _selectedAnswer != null &&
      currentQuestion != null &&
      _selectedAnswer == currentQuestion!.answer;

  Future<void> startZone(String zoneId) async {
    _phase = GamePhase.loading;
    _activeZoneId = zoneId;
    _questionIndex = 0;
    _sessionScore = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _selectedAnswer = null;
    _answered = false;
    _retryCount = 0;
    _triedWrongAnswers.clear();
    notifyListeners();
    _questions = await _repo.getSessionQuestions(zoneId);
    _phase = _questions.isEmpty ? GamePhase.idle : GamePhase.question;
    notifyListeners();
  }

  int submitAnswer(int choiceIndex) {
    if (_answered) return 0;
    _selectedAnswer = choiceIndex;
    final correct = choiceIndex == currentQuestion!.answer;
    int bricksEarned = 0;
    if (correct) {
      _answered = true;
      _phase = GamePhase.correct;
      bricksEarned = currentQuestion!.bricksReward;
      _sessionScore += bricksEarned;
      _correctCount++;
    } else {
      _triedWrongAnswers.add(choiceIndex);
      _phase = GamePhase.wrong;
      _wrongCount++;
    }
    notifyListeners();
    return bricksEarned;
  }

  void tryAgain() {
    _retryCount++;
    _selectedAnswer = null;
    _phase = GamePhase.question;
    notifyListeners();
  }

  void nextQuestion() {
    _questionIndex++;
    _selectedAnswer = null;
    _answered = false;
    _retryCount = 0;
    _triedWrongAnswers.clear();
    _phase = _questionIndex >= _questions.length
        ? GamePhase.zoneComplete : GamePhase.question;
    notifyListeners();
  }

  void reset() {
    _phase = GamePhase.idle;
    _activeZoneId = null;
    _questions = [];
    _questionIndex = 0;
    _sessionScore = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _selectedAnswer = null;
    _answered = false;
    _retryCount = 0;
    _triedWrongAnswers.clear();
    notifyListeners();
  }
}
