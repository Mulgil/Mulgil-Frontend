abstract final class AcademicCalendar {
  static int currentWeekNumber([DateTime? now]) {
    final n = now ?? DateTime.now();
    final springStart = DateTime(n.year, 3, 2);
    final fallStart = DateTime(n.year, 9, 1);
    final DateTime start;
    if (n.isBefore(springStart)) {
      start = DateTime(n.year - 1, 9, 1);
    } else if (n.isBefore(fallStart)) {
      start = springStart;
    } else {
      start = fallStart;
    }
    return (n.difference(start).inDays ~/ 7) + 1;
  }

  static String currentWeekLabel([DateTime? now]) =>
      '${currentWeekNumber(now)}주차';
}
