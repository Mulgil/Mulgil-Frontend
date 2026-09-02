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
              Exam(
                id: 'exam-1',
                courseId: 'course-1',
                courseName: '운영체제',
                title: '중간고사',
                examAt: DateTime.now().add(const Duration(days: 7)),
                sessionTitles: const ['1주차'],
                sessionIds: const ['session-1'],
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
              Exam(
                id: 'exam-1',
                courseId: 'course-1',
                courseName: '운영체제',
                title: '중간고사',
                examAt: DateTime.now().add(const Duration(days: 7)),
                sessionTitles: const ['1주차'],
                sessionIds: const ['session-1'],
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
}
