class QuestionEntity {
  final String question;
  final List<String> choices;
  final String correct;
  final String? rawJson;

  const QuestionEntity({
    required this.question,
    required this.choices,
    required this.correct,
    this.rawJson
  });
}