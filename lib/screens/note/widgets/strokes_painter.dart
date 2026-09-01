import 'package:flutter/material.dart';
import '../../../models/draw_stroke.dart';

class StrokesPainter extends CustomPainter {
  final List<DrawStroke> strokes;
  final DrawStroke? current;
  StrokesPainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in [...strokes, ?current]) {
      if (s.points.length < 2) continue;
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (final p in s.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  // `strokes` is mutated in place (add/remove) rather than replaced, so comparing
  // list identity here would never detect erase/undo/redo changes — always repaint instead.
  @override
  bool shouldRepaint(covariant StrokesPainter oldDelegate) => true;
}
