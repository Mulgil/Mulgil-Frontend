import 'package:flutter/material.dart';
import '../../../constants/routes.dart';
import '../../../models/wrong_answer.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class WrongAnswerCard extends StatelessWidget {
  final WrongAnswer item;
  const WrongAnswerCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.courseName,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.question,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '내 답: ${item.myAnswer}',
                style: const TextStyle(fontSize: 12, color: AppColors.coral),
              ),
              const SizedBox(width: 10),
              Text(
                '정답: ${item.correct}',
                style: const TextStyle(fontSize: 12, color: AppColors.tealDark),
              ),
            ],
          ),
          if (item.isProfEmphasis) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.coralSoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text(
                '교수님 강조 개념',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.navy),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: const Text(
                '다시 풀기',
                style: TextStyle(fontSize: 12, color: AppColors.navy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}