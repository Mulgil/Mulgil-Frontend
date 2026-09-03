import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/learning_domain_store.dart';
import '../../models/course.dart';
import '../../models/lecture.dart';
import '../../utils/academic_calendar.dart';
import 'quiz_session_screen.dart';

class QuizScreen extends StatefulWidget {
  final String? initialCourse;
  const QuizScreen({super.key, this.initialCourse});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _courseName;
  final _learningStore = LearningDomainStore.instance;

  @override
  void initState() {
    super.initState();
    _courseName = widget.initialCourse;
    unawaited(_learningStore.load());
  }

  Course? _selectedCourse() {
    final courses = _learningStore.courses;
    if (courses.isEmpty) return null;
    final selectedName = _courseName;
    if (selectedName != null) {
      for (final course in courses) {
        if (course.name == selectedName) return course;
      }
    }
    return courses.first;
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.isTablet ? 28.0 : 20.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: ListenableBuilder(
            listenable: _learningStore,
            builder: (context, _) {
              final selectedCourse = _selectedCourse();
              return Column(
                children: [
                  Row(
                    children: [
                      const BackIfPushed(),
                      Expanded(child: _buildCourseHeader(selectedCourse)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildQuizWeekList(context, selectedCourse)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader(Course? selectedCourse) {
    if (selectedCourse == null) {
      return Text('퀴즈', style: AppTextStyles.h2);
    }
    return CourseDropdown(
      selected: selectedCourse.name,
      options: _learningStore.courseNames,
      onChanged: (value) => setState(() => _courseName = value),
    );
  }

  Widget _buildQuizWeekList(BuildContext context, Course? selectedCourse) {
    if (_learningStore.isLoading && !_learningStore.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_learningStore.needsAuthentication ||
        _learningStore.errorMessage != null) {
      return _QuizStatusNotice(
        message:
            _learningStore.errorMessage ??
            'Google 로그인 토큰이 연결되면 서버 퀴즈 목록을 불러와요.',
        onRetry: _learningStore.refresh,
      );
    }
    if (selectedCourse == null) {
      return const Center(
        child: Text(
          '등록된 과목이 없어요',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    final lectures = _learningStore.sessionsFor(selectedCourse.id);
    if (lectures.isEmpty) {
      return Center(
        child: Text(
          '${selectedCourse.name} 과목에는 아직 차시가 없어요',
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.separated(
      itemCount: lectures.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final lecture = lectures[i];
        return _QuizWeekCard(
          lecture: lecture,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuizSessionScreen(
                course: selectedCourse.name,
                lecture: lecture,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuizWeekCard extends StatelessWidget {
  final Lecture lecture;
  final VoidCallback? onTap;
  const _QuizWeekCard({required this.lecture, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${lecture.week} - ${lecture.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lecture.week ==
                        AcademicCalendar.currentWeekLabel()) ...[
                      const SizedBox(width: 6),
                      const CurrentWeekBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  '퀴즈 확인',
                  style: TextStyle(fontSize: 11, color: AppColors.ink40),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.ink40),
        ],
      ),
    );
  }
}

class _QuizStatusNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _QuizStatusNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
