class Quiz {
  final String id;
  final String skillId;
  final String title;
  final List<Question> questions;

  const Quiz({
    required this.id,
    required this.skillId,
    required this.title,
    required this.questions,
  });
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });
}

class QuizAttempt {
  final String id;
  final String quizId;
  final String userId;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final double score;
  final DateTime timestamp;
  final String status; // pending, approved, rejected

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.answers,
    required this.score,
    required this.timestamp,
    this.status = 'pending',
  });
}
