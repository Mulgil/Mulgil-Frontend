import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import '../../../theme/app_theme.dart';

class WrongAnswerStatsCard extends StatelessWidget {
  const WrongAnswerStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번 학기 오답',
            style: TextStyle(fontSize: 13, color: Color(0xFF9fb6c4)),
          ),
          const SizedBox(height: 4),
          Text(
            '${MockData.wrongAnswers.length}개',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}