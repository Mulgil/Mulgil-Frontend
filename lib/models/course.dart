class Course {
  final String id;
  final String name;
  final String? instructor;
  final String? term;

  const Course({
    required this.id,
    required this.name,
    this.instructor,
    this.term,
  });
}
