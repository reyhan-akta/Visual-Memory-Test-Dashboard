import '../../domain/entities/questiton_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.question,
    required super.choices,
    required super.correct,
    required super.difficulty,
  });

  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      question: entity.question,
      choices: entity.choices,
      correct: entity.correct,
      difficulty: entity.difficulty,
    );
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      choices: List<String>.from(map['choices'] ?? []),
      correct: map['correct'] ?? '',
      difficulty: map['difficulty'] ?? 'orta',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'choices': choices,
      'correct': correct,
      'difficulty': difficulty,
    };
  }

  QuestionEntity toEntity() {
    return QuestionEntity(
      question: question,
      choices: choices,
      correct: correct,
      difficulty: difficulty,
    );
  }

}