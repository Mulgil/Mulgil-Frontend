import 'source_ref.dart';

// Mirrors POST /quiz/questions/{questionId}/attempts -> QuizAttemptResult —
// the only response that reveals a question's correct answer and explanation.
class QuizAttemptResult {
  final String attemptId;
  final bool isCorrect;
  final QuizAnswerFact answer;
  final QuizExplanation explanation;
  final QuizProgress progress;

  const QuizAttemptResult({
    required this.attemptId,
    required this.isCorrect,
    required this.answer,
    required this.explanation,
    required this.progress,
  });
}

// value is bool for a true_false question, int (0..3) for multiple_choice —
// matching the shape of the submitted `answer` request field.
class QuizAnswerFact {
  final Object value;
  final List<SourceRef> sourceRefs;

  const QuizAnswerFact({required this.value, this.sourceRefs = const []});
}

class QuizExplanation {
  final String text;
  final List<SourceRef> sourceRefs;

  const QuizExplanation({required this.text, this.sourceRefs = const []});
}

// Session-level progress projection returned alongside each attempt result.
class QuizProgress {
  final String sessionId;
  final int correctCount;
  final int incorrectCount;
  final DateTime lastAttemptAt;
  final DateTime updatedAt;

  const QuizProgress({
    required this.sessionId,
    required this.correctCount,
    required this.incorrectCount,
    required this.lastAttemptAt,
    required this.updatedAt,
  });
}
