class Lecture {
  final String id;
  final String courseId;
  final int? sessionNumber;
  final int? weekNumber;
  final String week;
  final String title;
  final String? date;
  final bool done;
  final String? quiz;
  final int stars;

  const Lecture({
    required this.id,
    required this.courseId,
    this.sessionNumber,
    this.weekNumber,
    required this.week,
    required this.title,
    this.date,
    required this.done,
    this.quiz,
    required this.stars,
  });
}
