enum QuizType { trueFalse, multipleChoice }

class QuizQuestion {
  final QuizType type;
  final String question;
  final List<String>? options; // exactly 4 entries when type is multipleChoice
  final int answer; // true_false: 0 = O, 1 = X · multiple_choice: 0..3 index into options
  final String explanation;

  const QuizQuestion({
    this.type = QuizType.trueFalse,
    required this.question,
    this.options,
    required this.answer,
    required this.explanation,
  });
}
