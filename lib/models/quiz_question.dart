class QuizQuestion {
  final String question;
  final int answer; // 0 = O, 1 = X
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.answer,
    required this.explanation,
  });
}
