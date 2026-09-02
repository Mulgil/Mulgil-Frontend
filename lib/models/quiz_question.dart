import 'source_ref.dart';

enum QuizType { trueFalse, multipleChoice }

// Mirrors GET /sessions/{sessionId}/quiz -> QuizQuestion. The question-fetch
// response withholds the correct answer and explanation; those are only
// revealed by POST /quiz/questions/{questionId}/attempts.
class QuizQuestion {
  final String id;
  final QuizType type;
  final String prompt;
  final List<String>? options; // exactly 4 entries when type is multipleChoice
  final List<SourceRef> sourceRefs;

  const QuizQuestion({
    required this.id,
    this.type = QuizType.trueFalse,
    required this.prompt,
    this.options,
    this.sourceRefs = const [],
  });
}
