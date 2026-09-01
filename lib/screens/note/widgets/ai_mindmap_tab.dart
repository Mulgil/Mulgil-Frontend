import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../data/mock_data.dart';

class MindmapTab extends StatelessWidget {
  const MindmapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          height: 340,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: CustomPaint(
            painter: MindmapPainter(
              centerLabel: MockData.mindmapCenterLabel,
              nodeLabels: MockData.mindmapNodeLabels,
            ),
            child: const Center(),
          ),
        ),
      ),
    );
  }
}

// Fixed 4-node radial layout — the offsets are a visual template, not data,
// so `nodeLabels` must have exactly 4 entries to match.
class MindmapPainter extends CustomPainter {
  final String centerLabel;
  final List<String> nodeLabels;
  MindmapPainter({required this.centerLabel, required this.nodeLabels})
    : assert(nodeLabels.length == 4);

  static const _offsets = [
    Offset(-120, -80),
    Offset(120, -80),
    Offset(-120, 80),
    Offset(120, 80),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final linePaint = Paint()
      ..color = const Color(0xFFB0C8D4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final centerPaint = Paint()..color = AppColors.navy;
    final nodePaint = Paint()..color = AppColors.teal.withValues(alpha: 0.8);

    canvas.drawCircle(Offset(cx, cy), 42, centerPaint);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: centerLabel,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    // Bounds the loop to whichever list is shorter so a `nodeLabels` list
    // that drifts from 4 entries can't index past either array — the assert
    // below is a debug-time early warning, not the actual safety net (Dart
    // strips asserts from release builds).
    final nodeCount = math.min(_offsets.length, nodeLabels.length);
    for (var i = 0; i < nodeCount; i++) {
      final dx = _offsets[i].dx;
      final dy = _offsets[i].dy;
      canvas.drawLine(Offset(cx, cy), Offset(cx + dx, cy + dy), linePaint);
      canvas.drawCircle(Offset(cx + dx, cy + dy), 28, nodePaint);
      final lbl = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: nodeLabels[i],
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
      lbl.layout();
      lbl.paint(
        canvas,
        Offset(cx + dx - lbl.width / 2, cy + dy - lbl.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
