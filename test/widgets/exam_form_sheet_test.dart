import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/models/course.dart';
import 'package:mulgil/models/lecture.dart';
import 'package:mulgil/widgets/common_widgets.dart';
import 'package:mulgil/widgets/exam_form_sheet.dart';

void main() {
  testWidgets('submits only sessions belonging to the selected course', (
    tester,
  ) async {
    Course? submittedCourse;
    List<Lecture>? submittedSessions;
    String? submittedTitle;

    const course = Course(id: 'course-1', name: '운영체제');
    const otherCourse = Course(id: 'course-2', name: '네트워크');
    const sessions = [
      Lecture(
        id: 'session-1',
        courseId: 'course-1',
        week: '1주차',
        title: '1차시',
        done: false,
        stars: 0,
      ),
      Lecture(
        id: 'session-2',
        courseId: 'course-2',
        week: '1주차',
        title: '다른 과목 차시',
        done: false,
        stars: 0,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showMulgilSheet<void>(
                context,
                isScrollControlled: true,
                builder: (_) => ExamFormSheet(
                  courses: const [course, otherCourse],
                  sessions: sessions,
                  onCreate:
                      ({
                        required course,
                        required title,
                        required examAt,
                        required sessions,
                      }) async {
                        submittedCourse = course;
                        submittedTitle = title;
                        submittedSessions = sessions;
                      },
                ),
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(find.text('1주차 · 1차시'), findsOneWidget);
    expect(find.text('1주차 · 다른 과목 차시'), findsNothing);

    await tester.enterText(find.byType(TextField), '중간고사');
    await tester.tap(find.text('1주차 · 1차시'));
    await tester.tap(find.text('등록'));
    await tester.pumpAndSettle();

    expect(submittedCourse, course);
    expect(submittedTitle, '중간고사');
    expect(submittedSessions, [sessions.first]);
  });
}
