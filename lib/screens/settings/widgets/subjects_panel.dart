import 'dart:async';

import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import '../../../models/course.dart';
import '../../../models/exam.dart';
import '../../../models/timetable_slot.dart';
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
  final List<Course>? courses;
  final List<TimetableSlot>? timetableSlots;
  final List<Exam>? exams;
  final FutureOr<void> Function(Course course, List<TimetableSlot> slots)?
  onAddCourse;
  final FutureOr<void> Function(Course course)? onDeleteCourse;
  final bool isLoading;
  final bool needsAuthentication;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const SettingsSubjectsPanel({
    super.key,
    required this.onAddSubject,
    required this.onAddExam,
    required this.onEditExam,
    required this.onDeleteExam,
    required this.onChanged,
    this.courses,
    this.timetableSlots,
    this.exams,
    this.onAddCourse,
    this.onDeleteCourse,
    this.isLoading = false,
    this.needsAuthentication = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final visibleExams = exams ?? MockData.exams;
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
        if (isLoading) ...[
          const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: 10),
        ],
        if (needsAuthentication || errorMessage != null) ...[
          _SubjectPanelNotice(
            message: errorMessage ?? 'Google 로그인 토큰이 연결되면 서버에 저장된 과목을 불러와요.',
            onRetry: onRetry,
          ),
          const SizedBox(height: 10),
        ],
        WeeklyTimetable(
          courses: courses,
          slots: timetableSlots,
          onAdd: onAddCourse,
          onDeleteCourse: onDeleteCourse,
          onChanged: onChanged,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: SectionLabel(label: '시험 일정')),
            MulgilRaisedAddButton(onTap: onAddExam),
          ],
        ),
        if (visibleExams.isEmpty)
          const EmptyExamBox()
        else
          ...visibleExams.map(
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

class _SubjectPanelNotice extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _SubjectPanelNotice({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
