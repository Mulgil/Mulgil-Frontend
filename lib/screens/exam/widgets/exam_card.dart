import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../models/exam.dart';
import '../../../utils/exam_dates.dart';
import 'job_button.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onAttachPastExam;
  final VoidCallback onGenerateSummary;
  final VoidCallback onGenerateQuiz;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const ExamCard({
    super.key,
    required this.exam,
    required this.onAttachPastExam,
    required this.onGenerateSummary,
    required this.onGenerateQuiz,
    required this.onEdit,
    required this.onDelete,
  });

  int get _dDay => examDday(exam.examAt);

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExamDayBadge(dDay: _dDay < 0 ? 0 : _dDay),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.courseName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      exam.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textLight,
                ),
                padding: EdgeInsets.zero,
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: exam.sessionTitles
                .map((s) => MulgilChip(label: s))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: exam.hasPastExamAttached ? null : onAttachPastExam,
                  icon: Icon(
                    exam.hasPastExamAttached ? Icons.check : Icons.upload_file,
                    size: 16,
                  ),
                  label: Text(
                    exam.hasPastExamAttached ? '기출 첨부됨' : '기출 PDF 첨부',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.navy),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: JobButton(
                  label: '요약 생성',
                  status: exam.summaryStatus,
                  onTap: onGenerateSummary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: JobButton(
                  label: '예상 문제 생성',
                  status: exam.quizStatus,
                  onTap: onGenerateQuiz,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '※ 첨부된 기출을 바탕으로 한 예상일 뿐, 실제 기출 제공이나 적중을 보장하지 않아요',
            style: TextStyle(fontSize: 10.5, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
