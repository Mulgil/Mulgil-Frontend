import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/utils/exam_dates.dart';

void main() {
  test('examDday compares calendar dates instead of full durations', () {
    final lateToday = DateTime(2026, 9, 3, 23, 30);
    final tomorrowMidnight = DateTime(2026, 9, 4);

    expect(examDday(tomorrowMidnight, today: lateToday), 1);
  });

  test('isUpcomingExam excludes dates before today', () {
    final today = DateTime(2026, 9, 3, 12);

    expect(isUpcomingExam(DateTime(2026, 9, 2), today: today), isFalse);
    expect(isUpcomingExam(DateTime(2026, 9, 3), today: today), isTrue);
    expect(isUpcomingExam(DateTime(2026, 9, 4), today: today), isTrue);
  });
}
