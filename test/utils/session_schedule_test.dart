import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/models/timetable_slot.dart';
import 'package:mulgil/utils/session_schedule.dart';

void main() {
  group('SessionSchedule.plan', () {
    test('creates one session for each of 16 weeks', () {
      final sessions = SessionSchedule.plan(
        semesterStart: DateTime(2026, 9, 1),
        slots: const [
          TimetableSlot(
            id: 'monday',
            courseId: 'course-1',
            weekday: DateTime.monday,
            startTime: '09:00',
            endTime: '10:15',
          ),
        ],
      );

      expect(sessions, hasLength(16));
      expect(sessions.first.sessionNumber, 1);
      expect(sessions.first.weekNumber, 1);
      expect(sessions.first.sessionInWeek, 1);
      expect(sessions.first.title, '1차시');
      expect(sessions.first.sessionDate, DateTime(2026, 9, 7));
      expect(sessions.first.startsAt, DateTime.utc(2026, 9, 7, 0));
      expect(sessions.first.endsAt, DateTime.utc(2026, 9, 7, 1, 15));
      expect(sessions.last.sessionNumber, 16);
      expect(sessions.last.weekNumber, 16);
      expect(sessions.last.sessionDate, DateTime(2026, 12, 21));
    });

    test('creates and orders every weekly meeting inside each week', () {
      final sessions = SessionSchedule.plan(
        semesterStart: DateTime(2026, 9, 1),
        slots: const [
          TimetableSlot(
            id: 'thursday',
            courseId: 'course-1',
            weekday: DateTime.thursday,
            startTime: '13:00',
            endTime: '14:15',
          ),
          TimetableSlot(
            id: 'tuesday',
            courseId: 'course-1',
            weekday: DateTime.tuesday,
            startTime: '10:30',
            endTime: '11:45',
          ),
        ],
      );

      expect(sessions, hasLength(32));
      expect(sessions.take(4).map((session) => session.sessionNumber), [
        1,
        2,
        3,
        4,
      ]);
      expect(sessions.take(4).map((session) => session.weekNumber), [
        1,
        1,
        2,
        2,
      ]);
      expect(sessions.take(4).map((session) => session.title), [
        '1차시',
        '2차시',
        '1차시',
        '2차시',
      ]);
      expect(sessions.take(4).map((session) => session.sessionDate), [
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 3),
        DateTime(2026, 9, 8),
        DateTime(2026, 9, 10),
      ]);
    });

    test('returns no sessions when no timetable slots exist', () {
      expect(
        SessionSchedule.plan(
          slots: const [],
          semesterStart: DateTime(2026, 9, 1),
        ),
        isEmpty,
      );
    });
  });
}
