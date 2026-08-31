import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/data/mock_data.dart';

void main() {
  group('ReplaceById.replaceWhere', () {
    test('replaces the first matching element and returns true', () {
      final list = [1, 2, 3];
      final changed = list.replaceWhere((n) => n == 2, 20);
      expect(changed, isTrue);
      expect(list, [1, 20, 3]);
    });

    test('no-ops and returns false when nothing matches', () {
      final list = [1, 2, 3];
      final changed = list.replaceWhere((n) => n == 99, 20);
      expect(changed, isFalse);
      expect(list, [1, 2, 3]);
    });
  });

  group('MockData.todaysSlot', () {
    test('returns the earliest slot for a weekday with classes', () {
      // Monday: 운영체제(c1) is the only course meeting, 09:00~10:15.
      final monday = DateTime(2026, 8, 31); // a Monday
      final slot = MockData.todaysSlot(monday);
      expect(slot, isNotNull);
      expect(slot!.courseId, 'c1');
      expect(slot.startTime, '09:00');
    });

    test(
      'ignores time of day — a class scheduled today still counts late at night',
      () {
        final mondayNight = DateTime(2026, 8, 31, 23, 0);
        final slot = MockData.todaysSlot(mondayNight);
        expect(slot, isNotNull);
        expect(slot!.courseId, 'c1');
      },
    );

    test('returns null for a weekday with no classes', () {
      final saturday = DateTime(2026, 9, 5); // a Saturday
      expect(MockData.todaysSlot(saturday), isNull);
    });

    test('picks the earliest of multiple same-day classes', () {
      // Friday: 자료구조(c2) at 10:30 and 데이터베이스(c3) at 15:00.
      final friday = DateTime(2026, 9, 4);
      final slot = MockData.todaysSlot(friday);
      expect(slot, isNotNull);
      expect(slot!.courseId, 'c2');
      expect(slot.startTime, '10:30');
    });
  });

  group('MockData.courseById / courseByName', () {
    test('courseById finds a known course', () {
      final course = MockData.courseById('c1');
      expect(course, isNotNull);
      expect(course!.name, '운영체제');
    });

    test('courseById returns null for an unknown id', () {
      expect(MockData.courseById('does-not-exist'), isNull);
    });

    test('courseByName finds a known course', () {
      final course = MockData.courseByName('자료구조');
      expect(course, isNotNull);
      expect(course!.id, 'c2');
    });

    test('courseByName returns null for an unknown name', () {
      expect(MockData.courseByName('없는 과목'), isNull);
    });
  });

  group('MockData.slotsFor / slotsSummary', () {
    test('slotsFor returns every slot for a course', () {
      expect(MockData.slotsFor('c1').length, 2);
    });

    test('slotsFor returns an empty list for a course with no slots', () {
      expect(MockData.slotsFor('does-not-exist'), isEmpty);
    });

    test(
      'slotsSummary falls back to a placeholder when there are no slots',
      () {
        expect(MockData.slotsSummary('does-not-exist'), '시간표 없음');
      },
    );
  });
}
