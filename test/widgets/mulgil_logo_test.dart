import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/theme/app_theme.dart';
import 'package:mulgil/widgets/mulgil_logo.dart';

void main() {
  testWidgets('uses the bundled Nunito font on every platform', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('logo', style: AppTextStyles.logoStyle),
              const MulgilWordmark(),
            ],
          ),
        ),
      ),
    );

    const expectedFontFamily = 'Nunito';
    final logoStyle = tester.widget<Text>(find.text('logo')).style!;
    final wordmarkStyle = tester.widget<Text>(find.text('mulg')).style!;
    expect(logoStyle.fontFamily, expectedFontFamily);
    expect(logoStyle.fontSize, 48);
    expect(logoStyle.fontWeight, FontWeight.w900);
    expect(logoStyle.color, Colors.white);
    expect(wordmarkStyle.fontFamily, expectedFontFamily);
    expect(wordmarkStyle.fontSize, 48);
    expect(wordmarkStyle.fontWeight, FontWeight.w900);
    expect(wordmarkStyle.color, Colors.white);
    expect(wordmarkStyle.height, 1);
  });
}
