import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/models/exam.dart';
import 'package:mulgil/screens/home/widgets/upcoming_exams_card.dart';

void main() {
  testWidgets('does not navigate to the mock exam route for injected exams', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/exams': (_) => const Scaffold(body: Text('mock exam route')),
        },
        home: Scaffold(
          body: UpcomingExamsCard(
            exams: [
              _exam(
                id: 'exam-1',
                courseId: 'course-1',
                courseName: '운영체제',
                title: '중간고사',
                examAt: DateTime.now().add(const Duration(days: 7)),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('운영체제 · 중간고사'));
    await tester.pumpAndSettle();

    expect(find.text('mock exam route'), findsNothing);
  });

  testWidgets('calls the provided tap handler for injected exams', (
    tester,
  ) async {
    Exam? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingExamsCard(
            exams: [
              _exam(
                id: 'exam-1',
                courseId: 'course-1',
                courseName: '운영체제',
                title: '중간고사',
                examAt: DateTime.now().add(const Duration(days: 7)),
              ),
            ],
            onExamTap: (exam) => selected = exam,
          ),
        ),
      ),
    );

    await tester.tap(find.text('운영체제 · 중간고사'));

    expect(selected?.id, 'exam-1');
  });

  testWidgets('hides past exams from upcoming exams', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingExamsCard(
            exams: [
              _exam(
                id: 'past-exam',
                courseName: '자료구조',
                title: '중간고사',
                examAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
              _exam(
                id: 'future-exam',
                courseName: '운영체제',
                title: '기말고사',
                examAt: DateTime.now().add(const Duration(days: 7)),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('자료구조 · 중간고사'), findsNothing);
    expect(find.text('운영체제 · 기말고사'), findsOneWidget);
  });

  testWidgets('shows D-day by calendar date', (tester) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingExamsCard(
            exams: [
              _exam(
                id: 'exam-1',
                courseName: '운영체제',
                title: '중간고사',
                examAt: tomorrow,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('D-1'), findsOneWidget);
  });
}

Exam _exam({
  required String id,
  String? courseId,
  required String courseName,
  required String title,
  required DateTime examAt,
}) {
  return Exam(
    id: id,
    courseId: courseId,
    courseName: courseName,
    title: title,
    examAt: examAt,
    sessionTitles: const ['1주차'],
    sessionIds: const ['session-1'],
  );
}
