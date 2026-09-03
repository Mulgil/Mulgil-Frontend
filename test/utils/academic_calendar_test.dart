import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/utils/academic_calendar.dart';

void main() {
  group('AcademicCalendar.currentWeekNumber', () {
    test('uses the spring semester start before fall semester starts', () {
      expect(AcademicCalendar.currentWeekNumber(DateTime(2026, 3, 2)), 1);
      expect(AcademicCalendar.currentWeekNumber(DateTime(2026, 3, 8)), 1);
      expect(AcademicCalendar.currentWeekNumber(DateTime(2026, 3, 9)), 2);
    });

    test('uses the fall semester start from September first', () {
      expect(AcademicCalendar.currentWeekNumber(DateTime(2026, 9, 1)), 1);
      expect(AcademicCalendar.currentWeekLabel(DateTime(2026, 9, 8)), '2주차');
    });

    test('falls back to the previous fall semester before spring starts', () {
      expect(AcademicCalendar.currentWeekNumber(DateTime(2026, 1, 1)), 18);
    });
  });
}
