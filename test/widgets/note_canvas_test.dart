import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/models/draw_stroke.dart';
import 'package:mulgil/screens/note/widgets/note_canvas.dart';

void main() {
  testWidgets('uses tap and long press callbacks for professor mentions', (
    tester,
  ) async {
    var drawStarts = 0;
    Offset? tapPosition;
    Offset? longPressPosition;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: NoteCanvas(
              strokes: const <DrawStroke>[],
              currentStroke: null,
              mentions: const [],
              onDrawStart: (_) => drawStarts += 1,
              onDrawUpdate: (_) {},
              onDrawEnd: () {},
              onMentionTap: (position) => tapPosition = position,
              onMentionLongPress: (position) => longPressPosition = position,
            ),
          ),
        ),
      ),
    );

    final canvas = find.byType(NoteCanvas);
    final position = tester.getCenter(canvas);

    await tester.tapAt(position);
    await tester.pump();
    expect(tapPosition, isNotNull);
    expect(drawStarts, 0);

    await tester.longPressAt(position);
    await tester.pump();
    expect(longPressPosition, isNotNull);
    expect(drawStarts, 0);
  });
}
