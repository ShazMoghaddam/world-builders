class Question {
  final String id;
  final String zone;
  final String prompt;
  final List<String> choices;
  final int answer; // index into choices
  final int bricksReward;
  final String? bingoTag;

  const Question({
    required this.id,
    required this.zone,
    required this.prompt,
    required this.choices,
    required this.answer,
    required this.bricksReward,
    this.bingoTag,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        zone: json['zone'] as String,
        prompt: json['prompt'] as String,
        choices: List<String>.from(json['choices'] as List),
        answer: json['answer'] as int,
        bricksReward: json['bricksReward'] as int,
        bingoTag: json['bingoTag'] as String?,
      );
}
