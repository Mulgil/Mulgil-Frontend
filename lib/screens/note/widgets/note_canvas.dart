import 'package:flutter/material.dart';

import '../../../models/draw_stroke.dart';
import '../../../theme/app_theme.dart';
import 'strokes_painter.dart';

class NoteCanvas extends StatelessWidget {
  final List<DrawStroke> strokes;
  final DrawStroke? currentStroke;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  const NoteCanvas({
    super.key,
    required this.strokes,
    required this.currentStroke,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: ClipRect(
        child: Stack(
          children: [
            Container(color: AppColors.bg),
            Positioned.fill(
              child: CustomPaint(
                painter: StrokesPainter(
                  strokes: strokes,
                  current: currentStroke,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
