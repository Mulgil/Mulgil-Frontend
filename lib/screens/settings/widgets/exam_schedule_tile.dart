import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../models/exam.dart';

class ExamScheduleTile extends StatelessWidget {
  final Exam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const ExamScheduleTile({
    super.key,
    required this.exam,
    required this.onEdit,
    required this.onDelete,
  });

  int get _dDay => exam.examAt.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final dDay = _dDay < 0 ? 0 : _dDay;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          ExamDayBadge(dDay: dDay),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: exam.courseName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(
                        text: ' · ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      TextSpan(
                        text: exam.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  '${exam.examAt.year}.${exam.examAt.month}.${exam.examAt.day}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppColors.textLight,
            ),
            onPressed: onEdit,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 16,
              color: AppColors.coral,
            ),
            onPressed: onDelete,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

class EmptyExamBox extends StatelessWidget {
  const EmptyExamBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Text(
        '등록된 시험이 없어요',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}
