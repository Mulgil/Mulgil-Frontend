import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class QuizResultCard extends StatelessWidget {
  final bool correct;
  final String explanation;

  const QuizResultCard({
    super.key,
    required this.correct,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        width: 170,
        child: MulgilCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                correct ? '정답!' : '오답',
                style: TextStyle(
                  color: correct ? AppColors.tealDark : AppColors.coral,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                explanation,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.ink80,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
