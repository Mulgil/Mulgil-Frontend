class Lecture {
  final String id;
  final String week;
  final String title;
  final String? date;
  final bool done;
  final String? quiz;
  final int stars;

  const Lecture({
    required this.id,
    required this.week,
    required this.title,
    this.date,
    required this.done,
    this.quiz,
    required this.stars,
  });
}
