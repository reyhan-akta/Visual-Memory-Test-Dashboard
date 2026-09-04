import '../../domain/entities/questiton_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.question,
    required super.choices,
    required super.correct,
    super.rawJson

  });

  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      question: entity.question,
      choices: entity.choices,
      correct: entity.correct,
      rawJson: entity.rawJson

    );
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map, {String? rawJson }) {
    return QuestionModel(
      question: map['question'] ?? '',
      choices: List<String>.from(map['choices'] ?? []),
      correct: map['correct'] ?? '',
      rawJson: rawJson
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'choices': choices,
      'correct': correct,

    };
  }

  QuestionEntity toEntity() {
    return QuestionEntity(
      question: question,
      choices: choices,
      correct: correct,
      rawJson: rawJson
    );
  }

}