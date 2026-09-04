import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/models/timetable_slot.dart';
import 'package:mulgil/theme/app_theme.dart';
import 'package:mulgil/widgets/course_form_sheet.dart';

void main() {
  testWidgets('creates independently timed slots for selected weekdays', (
    tester,
  ) async {
    List<TimetableSlot>? submittedSlots;
    var addCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: CourseFormSheet(
            onAdd: (_, slots) {
              addCalls += 1;
              submittedSlots = slots;
            },
          ),
        ),
      ),
    );

    // Given: one course is held on Monday and Wednesday.
    await tester.enterText(find.byType(TextField).first, '자료구조');
    await tester.tap(find.widgetWithText(ChoiceChip, '월'));
    await tester.tap(find.widgetWithText(ChoiceChip, '수'));
    await tester.pumpAndSettle();

    // When: each weekday receives a different start time.
    await _pickTime(tester, const ValueKey('course-time-start-1'), '10', '30');
    await _pickTime(tester, const ValueKey('course-time-end-1'), '11', '55');
    await _pickTime(tester, const ValueKey('course-time-start-3'), '8', '15');
    await _pickTime(tester, const ValueKey('course-time-end-3'), '9', '45');
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();

    // Then: the submitted slots retain each weekday's own time range.
    expect(addCalls, 1);
    expect(
      submittedSlots
          ?.map((slot) => '${slot.weekday}:${slot.startTime}-${slot.endTime}')
          .toList(),
      ['1:10:30-11:55', '3:08:15-09:45'],
    );
  });
}

Future<void> _pickTime(
  WidgetTester tester,
  Key key,
  String hour,
  String minute,
) async {
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();

  final dialog = find.byType(TimePickerDialog);
  await tester.tap(
    find.descendant(of: dialog, matching: find.byIcon(Icons.keyboard_outlined)),
  );
  await tester.pumpAndSettle();
  final inputs = find.descendant(
    of: dialog,
    matching: find.byType(EditableText),
  );
  await tester.enterText(inputs.first, hour);
  await tester.enterText(inputs.at(1), minute);
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: dialog, matching: find.byType(TextButton)).last,
  );
  await tester.pumpAndSettle();
}
