class QuestionEntity {
  final String question;
  final List<String> choices;
  final String correct;
  final String difficulty;

  const QuestionEntity({
    required this.question,
    required this.choices,
    required this.correct,
    required this.difficulty,
  });
}