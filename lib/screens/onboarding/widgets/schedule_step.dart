import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/auth_store.dart';
import '../../../data/learning_domain_store.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/course_form_sheet.dart';
import '../../../widgets/exam_form_sheet.dart';
import '../../../widgets/weekly_timetable.dart';
import '../../../models/course.dart';
import '../../../models/exam.dart';

// ── Schedule Setup ───────────────────────────────────

class ScheduleStep extends StatefulWidget {
  final VoidCallback onNext;
  const ScheduleStep({super.key, required this.onNext});

  @override
  State<ScheduleStep> createState() => _ScheduleStepState();
}

class _ScheduleStepState extends State<ScheduleStep> {
  final _learningStore = LearningDomainStore.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_learningStore.load());
  }

  void _openAddSubjectSheet() {
    if (!AuthStore.hasAccessToken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google 로그인 연결 후 서버에 저장할 수 있어요.')),
      );
      return;
    }
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => CourseFormSheet(
        existingSlots: _learningStore.timetableSlots,
        onAdd: _learningStore.createCourseWithSlots,
      ),
    );
  }

  List<Exam> _examsFor(Course course) =>
      _learningStore.exams.where((e) => e.courseId == course.id).toList();

  // Pass `existing` to edit that exam in place; omit it to add a new one —
  // a course can have zero, one, or several exams (중간/기말/퀴즈 등), so this
  // is called once per exam row rather than once per course.
  Future<void> _openExamSheet(Course course, {Exam? existing}) async {
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시험 수정 API가 아직 없어 화면 저장을 비워뒀어요.')),
      );
      return;
    }
    if (!AuthStore.hasAccessToken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google 로그인 연결 후 서버에 저장할 수 있어요.')),
      );
      return;
    }
    await showMulgilSheet<void>(
      context,
      isScrollControlled: true,
      builder: (_) => ExamFormSheet(
        initialCourse: course,
        courses: _learningStore.courses,
        sessions: _learningStore.sessions,
        onCreate: _learningStore.createExam,
      ),
    );
  }

  void _deleteExam(Exam _) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시험 삭제 API가 아직 없어 화면 저장을 비워뒀어요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '온보딩 2/2',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('시간표를 등록해주세요', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                const Text(
                  '과목·교수님·시험 일정을 알면 리마인더를 딱 맞게 보내드려요',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '시간표',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            MulgilRaisedAddButton(onTap: _openAddSubjectSheet),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ListenableBuilder(
                          listenable: _learningStore,
                          builder: (context, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_learningStore.isLoading) ...[
                                const LinearProgressIndicator(minHeight: 3),
                                const SizedBox(height: 10),
                              ],
                              if (_learningStore.needsAuthentication ||
                                  _learningStore.errorMessage != null) ...[
                                _ScheduleStatusNotice(
                                  message:
                                      _learningStore.errorMessage ??
                                      'Google 로그인 토큰이 연결되면 서버 시간표를 불러와요.',
                                ),
                                const SizedBox(height: 10),
                              ],
                              WeeklyTimetable(
                                courses: _learningStore.courses,
                                slots: _learningStore.timetableSlots,
                                onAdd: _learningStore.createCourseWithSlots,
                                onDeleteCourse: _learningStore.deleteCourse,
                                onChanged: () => setState(() {}),
                              ),
                              const SizedBox(height: 20),
                              const SectionHeader(
                                title: '시험 일정',
                                subtitle: '과목을 탭해서 시험 날짜를 등록해주세요',
                              ),
                              ..._learningStore.courses.map(
                                (course) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _ExamScheduleCard(
                                    course: course,
                                    exams: _examsFor(course),
                                    onAddExam: () => _openExamSheet(course),
                                    onEditExam: (exam) =>
                                        _openExamSheet(course, existing: exam),
                                    onDeleteExam: _deleteExam,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                MulgilButton(label: '완료', onTap: widget.onNext),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleStatusNotice extends StatelessWidget {
  final String message;

  const _ScheduleStatusNotice({required this.message});

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
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}

// A course can have zero, one, or several exams (중간고사·기말고사·퀴즈 등), so this
// renders the whole list for the course plus a row to add another — not a
// single exam slot per course.
class _ExamScheduleCard extends StatelessWidget {
  final Course course;
  final List<Exam> exams;
  final VoidCallback onAddExam;
  final ValueChanged<Exam> onEditExam;
  final ValueChanged<Exam> onDeleteExam;
  const _ExamScheduleCard({
    required this.course,
    required this.exams,
    required this.onAddExam,
    required this.onEditExam,
    required this.onDeleteExam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (course.instructor != null)
            Text(
              course.instructor!,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          const SizedBox(height: 10),
          if (exams.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                '등록된 시험이 없어요',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            )
          else
            ...exams.map(
              (exam) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onEditExam(exam),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${exam.title} · ${exam.examAt.month}월 ${exam.examAt.day}일',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onDeleteExam(exam),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.ink40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: onAddExam,
            behavior: HitTestBehavior.opaque,
            child: const Row(
              children: [
                Icon(Icons.add, size: 15, color: AppColors.tealDark),
                SizedBox(width: 4),
                Text(
                  '시험 추가',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
