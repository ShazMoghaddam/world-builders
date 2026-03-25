class BingoCell {
  final String id;
  final String tag; // matches Question.bingoTag
  final String label; // short display text e.g. "3 + 4"
  final String emoji;
  final bool isCompleted;
  final bool isFree; // centre free space

  const BingoCell({
    required this.id,
    required this.tag,
    required this.label,
    required this.emoji,
    this.isCompleted = false,
    this.isFree = false,
  });

  BingoCell copyWith({bool? isCompleted}) => BingoCell(
        id: id,
        tag: tag,
        label: label,
        emoji: emoji,
        isCompleted: isCompleted ?? this.isCompleted,
        isFree: isFree,
      );

  // All possible cells the board is built from
  static const List<BingoCell> pool = [
    // Math
    BingoCell(id: 'math-add',     tag: 'math-add',     label: 'Addition',    emoji: '➕'),
    BingoCell(id: 'math-sub',     tag: 'math-sub',     label: 'Subtraction', emoji: '➖'),
    BingoCell(id: 'math-count',   tag: 'math-count',   label: 'Counting',    emoji: '🔢'),
    BingoCell(id: 'math-shapes',  tag: 'math-shapes',  label: 'Shapes',      emoji: '🔷'),
    BingoCell(id: 'math-compare', tag: 'math-compare', label: 'Comparing',   emoji: '⚖️'),
    // Literacy
    BingoCell(id: 'lit-rhyme',    tag: 'lit-rhyme',    label: 'Rhyming',     emoji: '🎵'),
    BingoCell(id: 'lit-letters',  tag: 'lit-letters',  label: 'Letters',     emoji: '🔤'),
    BingoCell(id: 'lit-grammar',  tag: 'lit-grammar',  label: 'Grammar',     emoji: '📝'),
    BingoCell(id: 'lit-vowels',   tag: 'lit-vowels',   label: 'Vowels',      emoji: '🗣️'),
    BingoCell(id: 'lit-opposites',tag: 'lit-opposites',label: 'Opposites',   emoji: '↔️'),
    // Science
    BingoCell(id: 'sci-plants',   tag: 'sci-plants',   label: 'Plants',      emoji: '🌱'),
    BingoCell(id: 'sci-animals',  tag: 'sci-animals',  label: 'Animals',     emoji: '🐾'),
    BingoCell(id: 'sci-space',    tag: 'sci-space',    label: 'Space',       emoji: '🌍'),
    BingoCell(id: 'sci-matter',   tag: 'sci-matter',   label: 'Matter',      emoji: '🧊'),
    BingoCell(id: 'sci-biology',  tag: 'sci-biology',  label: 'Biology',     emoji: '🔬'),
    // Life skills
    BingoCell(id: 'life-hygiene', tag: 'life-hygiene', label: 'Hygiene',     emoji: '🧼'),
    BingoCell(id: 'life-empathy', tag: 'life-empathy', label: 'Empathy',     emoji: '💛'),
    BingoCell(id: 'life-health',  tag: 'life-health',  label: 'Health',      emoji: '🥗'),
    BingoCell(id: 'life-manners', tag: 'life-manners', label: 'Manners',     emoji: '🙏'),
    BingoCell(id: 'life-sleep',   tag: 'life-sleep',   label: 'Sleep',       emoji: '😴'), 
BingoCell(id: 'math-multiply', tag: 'math-multiply', label: 'Multiply',  emoji: '✖️'),
BingoCell(id: 'lit-reading',   tag: 'lit-reading',   label: 'Reading',   emoji: '📚'),
BingoCell(id: 'sci-weather',   tag: 'sci-weather',   label: 'Weather',   emoji: '🌤️'),
BingoCell(id: 'life-safety',   tag: 'life-safety',   label: 'Safety',    emoji: '🦺'),
    // Free space
    BingoCell(id: 'free', tag: '', label: 'FREE', emoji: '⭐', isFree: true, isCompleted: true),
  ];
}
