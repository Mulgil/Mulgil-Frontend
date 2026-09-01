import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import '../../../models/exam.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/weekly_timetable.dart';
import 'exam_schedule_tile.dart';
import 'panel_title.dart';
import 'section_label.dart';

class SettingsSubjectsPanel extends StatelessWidget {
  final VoidCallback onAddSubject;
  final VoidCallback onAddExam;
  final ValueChanged<Exam> onEditExam;
  final ValueChanged<Exam> onDeleteExam;
  final VoidCallback onChanged;

  const SettingsSubjectsPanel({
    super.key,
    required this.onAddSubject,
    required this.onAddExam,
    required this.onEditExam,
    required this.onDeleteExam,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const PanelTitle(title: '과목 관리'),
            const Spacer(),
            MulgilRaisedAddButton(onTap: onAddSubject),
          ],
        ),
        const SizedBox(height: 20),
        WeeklyTimetable(onChanged: onChanged),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: SectionLabel(label: '시험 일정')),
            MulgilRaisedAddButton(onTap: onAddExam),
          ],
        ),
        if (MockData.exams.isEmpty)
          const EmptyExamBox()
        else
          ...MockData.exams.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExamScheduleTile(
                exam: e,
                onEdit: () => onEditExam(e),
                onDelete: () => onDeleteExam(e),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.tealDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '과목을 추가하면 AI가 강의 패턴을 분석해 맞춤 퀴즈를 만들어요',
                  style: TextStyle(fontSize: 12, color: AppColors.tealDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}