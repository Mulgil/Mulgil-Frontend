import '../models/timetable_slot.dart';

class PlannedSession {
  final int sessionNumber;
  final int weekNumber;
  final int sessionInWeek;
  final String title;
  final DateTime sessionDate;
  final DateTime startsAt;
  final DateTime endsAt;

  const PlannedSession({
    required this.sessionNumber,
    required this.weekNumber,
    required this.sessionInWeek,
    required this.title,
    required this.sessionDate,
    required this.startsAt,
    required this.endsAt,
  });
}

abstract final class SessionSchedule {
  static const int defaultWeekCount = 16;
  static const Duration _seoulOffset = Duration(hours: 9);

  static List<PlannedSession> plan({
    required List<TimetableSlot> slots,
    required DateTime semesterStart,
    int weekCount = defaultWeekCount,
  }) {
    if (slots.isEmpty || weekCount <= 0) return const [];

    final start = DateTime(
      semesterStart.year,
      semesterStart.month,
      semesterStart.day,
    );
    final candidates = <_SessionCandidate>[];
    for (var weekNumber = 1; weekNumber <= weekCount; weekNumber++) {
      for (final slot in slots) {
        final firstOffset = (slot.weekday - start.weekday + 7) % 7;
        final date = start.add(
          Duration(days: firstOffset + (weekNumber - 1) * 7),
        );
        candidates.add(
          _SessionCandidate(weekNumber: weekNumber, date: date, slot: slot),
        );
      }
    }
    candidates.sort((a, b) {
      final dateOrder = a.date.compareTo(b.date);
      if (dateOrder != 0) return dateOrder;
      final timeOrder = a.slot.startMinutes.compareTo(b.slot.startMinutes);
      if (timeOrder != 0) return timeOrder;
      return a.slot.id.compareTo(b.slot.id);
    });

    final countsByWeek = <int, int>{};
    return candidates.indexed
        .map((entry) {
          final sessionNumber = entry.$1 + 1;
          final candidate = entry.$2;
          final sessionInWeek = (countsByWeek[candidate.weekNumber] ?? 0) + 1;
          countsByWeek[candidate.weekNumber] = sessionInWeek;
          return PlannedSession(
            sessionNumber: sessionNumber,
            weekNumber: candidate.weekNumber,
            sessionInWeek: sessionInWeek,
            title: '$sessionInWeek차시',
            sessionDate: candidate.date,
            startsAt: _seoulInstant(candidate.date, candidate.slot.startTime),
            endsAt: _seoulInstant(candidate.date, candidate.slot.endTime),
          );
        })
        .toList(growable: false);
  }

  static DateTime _seoulInstant(DateTime date, String time) {
    final parts = time.split(':');
    final localAsUtc = DateTime.utc(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return localAsUtc.subtract(_seoulOffset);
  }
}

class _SessionCandidate {
  final int weekNumber;
  final DateTime date;
  final TimetableSlot slot;

  const _SessionCandidate({
    required this.weekNumber,
    required this.date,
    required this.slot,
  });
}
