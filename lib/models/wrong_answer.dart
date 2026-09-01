class WrongAnswer {
  final String courseName;
  final String week;
  final String question;
  final String myAnswer;
  final String correct;
  final bool isProfEmphasis;

  const WrongAnswer({
    required this.courseName,
    required this.week,
    required this.question,
    required this.myAnswer,
    required this.correct,
    required this.isProfEmphasis,
  });
}
