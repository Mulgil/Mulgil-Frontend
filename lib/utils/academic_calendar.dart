abstract final class AcademicCalendar {
  static DateTime semesterStart([DateTime? now]) {
    final n = now ?? DateTime.now();
    final springStart = DateTime(n.year, 3, 2);
    final fallStart = DateTime(n.year, 9, 1);
    if (n.isBefore(springStart)) return DateTime(n.year - 1, 9, 1);
    if (n.isBefore(fallStart)) return springStart;
    return fallStart;
  }

  static DateTime semesterStartForTerm(String? term, {DateTime? fallback}) {
    final match = RegExp(
      r'^(\d{4})-(1|2|spring|fall)$',
      caseSensitive: false,
    ).firstMatch(term?.trim() ?? '');
    if (match == null) return semesterStart(fallback);
    final year = int.parse(match.group(1)!);
    final semester = match.group(2)!.toLowerCase();
    return semester == '1' || semester == 'spring'
        ? DateTime(year, 3, 2)
        : DateTime(year, 9, 1);
  }

  static String termCode([DateTime? now]) {
    final start = semesterStart(now);
    return '${start.year}-${start.month == 3 ? 1 : 2}';
  }

  static int weekNumberFor(DateTime date, {DateTime? semesterStart}) {
    final start = semesterStart ?? AcademicCalendar.semesterStart(date);
    return (DateTime(
              date.year,
              date.month,
              date.day,
            ).difference(start).inDays ~/
            7) +
        1;
  }

  static int currentWeekNumber([DateTime? now]) {
    final n = now ?? DateTime.now();
    return weekNumberFor(n, semesterStart: semesterStart(n));
  }

  static String currentWeekLabel([DateTime? now]) =>
      '${currentWeekNumber(now)}주차';
}
