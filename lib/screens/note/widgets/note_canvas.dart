import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import '../../../models/draw_stroke.dart';
import '../../../theme/app_theme.dart';
import 'strokes_painter.dart';

class NoteCanvas extends StatelessWidget {
  final bool showProfTag;
  final List<DrawStroke> strokes;
  final DrawStroke? currentStroke;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  const NoteCanvas({
    super.key,
    required this.showProfTag,
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
      child: Stack(
        children: [
          Container(
            color: AppColors.bg,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '텍스트입니다 텍스트입니다',
                  style: TextStyle(color: AppColors.ink80, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  '텍스트입니다',
                  style: TextStyle(color: AppColors.ink80, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.chip,
                    border: Border.all(
                      color: AppColors.ink20,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '이미지 / 다이어그램',
                    style: TextStyle(fontSize: 11, color: AppColors.ink40),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '텍스트입니다 텍스트입니다',
                  style: TextStyle(color: AppColors.ink80, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 16,
                      color: AppColors.yellow.withValues(alpha: 0.5),
                    ),
                    const Text(
                      '텍스트입니다',
                      style: TextStyle(color: AppColors.ink80, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showProfTag)
            Positioned(
              left: 40,
              top: 160,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 110,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.coral,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    left: 90,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text(
                        '⭐⭐',
                        style: TextStyle(fontSize: 9, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            left: 24,
            bottom: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                MockData.mentionFrequencyLabel,
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: StrokesPainter(strokes: strokes, current: currentStroke),
            ),
          ),
        ],
      ),
    );
  }
}
