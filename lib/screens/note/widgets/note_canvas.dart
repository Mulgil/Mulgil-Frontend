import 'package:flutter/material.dart';

import '../../../models/draw_stroke.dart';
import '../../../models/prof_mention.dart';
import '../../../theme/app_theme.dart';
import 'strokes_painter.dart';

class NoteCanvas extends StatelessWidget {
  final List<DrawStroke> strokes;
  final DrawStroke? currentStroke;
  final List<ProfMention> mentions;
  final Rect? mentionPreviewRect;
  final ValueChanged<Offset> onDrawStart;
  final ValueChanged<Offset> onDrawUpdate;
  final VoidCallback onDrawEnd;

  const NoteCanvas({
    super.key,
    required this.strokes,
    required this.currentStroke,
    required this.mentions,
    this.mentionPreviewRect,
    required this.onDrawStart,
    required this.onDrawUpdate,
    required this.onDrawEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounds = Offset.zero & constraints.biggest;
        Offset clamp(Offset o) => Offset(
          o.dx.clamp(bounds.left, bounds.right),
          o.dy.clamp(bounds.top, bounds.bottom),
        );
        return GestureDetector(
          onPanStart: (d) => onDrawStart(clamp(d.localPosition)),
          onPanUpdate: (d) => onDrawUpdate(clamp(d.localPosition)),
          onPanEnd: (_) => onDrawEnd(),
          child: ClipRect(child: _buildStack()),
        );
      },
    );
  }

  Widget _buildStack() {
    return Stack(
      children: [
        Container(color: AppColors.bg),
        for (final m in mentions) _buildMentionBox(m.rect, m.frequency),
        if (mentionPreviewRect != null)
          _buildMentionBox(mentionPreviewRect!, 1, preview: true),
        Positioned.fill(
          child: CustomPaint(
            painter: StrokesPainter(strokes: strokes, current: currentStroke),
          ),
        ),
      ],
    );
  }

  Widget _buildMentionBox(Rect rect, int frequency, {bool preview = false}) {
    return Positioned.fromRect(
      rect: rect,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.coral.withValues(alpha: preview ? 0.5 : 1),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          if (!preview)
            Positioned(
              top: -10,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '⭐' * frequency,
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
