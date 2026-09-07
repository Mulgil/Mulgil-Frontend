import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/resource_upload_api.dart';
import '../../../theme/app_theme.dart';

class MindmapTab extends StatelessWidget {
  final String centerLabel;
  final List<String> nodeLabels;
  final SessionProcessingJob? generationJob;

  const MindmapTab({
    super.key,
    required this.centerLabel,
    required this.nodeLabels,
    this.generationJob,
  });

  @override
  Widget build(BuildContext context) {
    final visibleLabels = nodeLabels.take(4).toList();
    if (visibleLabels.length < 4) {
      final job = generationJob;
      final title = job?.status.isActive == true
          ? '마인드맵 생성 중'
          : job?.status == ProcessingJobStatus.failed
          ? '마인드맵 생성에 실패했어요.'
          : '마인드맵이 아직 없어요';
      final detail = job?.status.isActive == true
          ? job!.safeProgressMessage
          : job?.status == ProcessingJobStatus.failed && job?.retryable == true
          ? '다시 시도해 주세요.'
          : null;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (job?.status.isActive == true)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }
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
              centerLabel: centerLabel,
              nodeLabels: visibleLabels,
            ),
            child: const Center(),
          ),
        ),
      ),
    );
  }
}

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
    tp.layout(maxWidth: 76);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

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
      lbl.layout(maxWidth: 52);
      lbl.paint(
        canvas,
        Offset(cx + dx - lbl.width / 2, cy + dy - lbl.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MindmapPainter old) {
    return old.centerLabel != centerLabel || old.nodeLabels != nodeLabels;
  }
}
