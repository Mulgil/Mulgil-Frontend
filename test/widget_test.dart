import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mulgil/main.dart';

void main() {
  testWidgets('App launches and shows the splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MulgilApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Splash screen navigates away after a delay; let that timer finish
    // instead of leaving it pending when the test ends.
    await tester.pump(const Duration(milliseconds: 1100));
  });
}
