import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/models/summary_item.dart';
import 'package:mulgil/screens/note/widgets/ai_summary_tab.dart';

void main() {
  testWidgets('keeps the Korean predicate ending together in the tablet card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final body = '${List.filled(29, '가').join()}생성돼요.';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SummaryTab(
            isTablet: true,
            items: [SummaryItem(title: '핵심 개념', body: body, isEmphasis: false)],
            onTakeQuiz: _noop,
          ),
        ),
      ),
    );

    final bodyFinder = find.textContaining('생성돼요.');
    final paragraph = tester.renderObject<RenderParagraph>(bodyFinder);
    final renderedText = tester.widget<Text>(bodyFinder).data!;
    final predicateStart = renderedText.indexOf('생성돼요.');
    final endingStart = renderedText.indexOf('돼요.');
    final predicateBox = paragraph
        .getBoxesForSelection(
          TextSelection(
            baseOffset: predicateStart,
            extentOffset: predicateStart + 1,
          ),
        )
        .single;
    final endingBox = paragraph
        .getBoxesForSelection(
          TextSelection(baseOffset: endingStart, extentOffset: endingStart + 1),
        )
        .single;

    expect(endingBox.top, predicateBox.top);
  });
}

void _noop() {}
