import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/weekly_timetable.dart';
import '../../data/auth_store.dart';
import '../../data/learning_domain_store.dart';
import '../../models/course.dart';
import '../../utils/academic_calendar.dart';
import '../note/note_list_screen.dart';
import '../note/ai_summary_screen.dart';
import '../quiz/quiz_screen.dart';
import '../../constants/routes.dart';
import 'widgets/header_icon_button.dart';
import 'widgets/notification_bell.dart';
import 'widgets/upcoming_exams_card.dart';

String _formatDate(DateTime d) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${d.year}년 ${d.month}월 ${d.day}일 ${weekdays[d.weekday - 1]}요일';
}

// Home is the timetable — like Everytime, tapping a subject block opens a
// sheet to jump straight into that subject's 필기/퀴즈/요약, instead of the
// old separate cards + bottom-nav tabs for each.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const HomeScreen({super.key, this.onOpenSettings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _sectionGap = 24.0;
  final _learningStore = LearningDomainStore.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_learningStore.load());
  }

  void _openCourseActionsSheet(BuildContext context, Course course) {
    showMulgilSheet(
      context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_note_outlined,
                color: AppColors.navy,
              ),
              title: const Text('필기'),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteListScreen(initialCourse: course.name),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz_outlined, color: AppColors.navy),
              title: const Text('퀴즈'),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(initialCourse: course.name),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.navy,
              ),
              title: const Text('요약'),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AiSummaryScreen(initialCourse: course.name),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final pad = context.isTablet ? 28.0 : 20.0;
    final userName = AuthStore.user?.displayLabel ?? '사용자';
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatDate(today)} · ${AcademicCalendar.currentWeekLabel(today)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.ink60,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('안녕하세요, $userName님', style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                  HeaderIconButton(
                    icon: Icons.settings_outlined,
                    onTap:
                        widget.onOpenSettings ??
                        () =>
                            Navigator.of(context).pushNamed(AppRoutes.settings),
                  ),
                  const SizedBox(width: 8),
                  const NotificationBell(),
                ],
              ),
              const SizedBox(height: _sectionGap),
              ListenableBuilder(
                listenable: _learningStore,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UpcomingExamsCard(
                      exams: _learningStore.exams,
                      onExamTap: (exam) => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.exams, arguments: exam),
                    ),
                    const SizedBox(height: _sectionGap),
                    const SectionHeader(title: '이번 주 시간표'),
                    const SizedBox(height: 10),
                    if (_learningStore.isLoading &&
                        !_learningStore.hasLoaded) ...[
                      const LinearProgressIndicator(minHeight: 3),
                      const SizedBox(height: 10),
                    ],
                    if (_learningStore.needsAuthentication ||
                        _learningStore.errorMessage != null) ...[
                      _LearningDomainNotice(
                        message:
                            _learningStore.errorMessage ??
                            'Google 로그인 토큰이 연결되면 서버 시간표를 불러와요.',
                      ),
                      const SizedBox(height: 10),
                    ],
                    WeeklyTimetable(
                      courses: _learningStore.courses,
                      slots: _learningStore.timetableSlots,
                      canEdit: false,
                      onCourseTap: (course) =>
                          _openCourseActionsSheet(context, course),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningDomainNotice extends StatelessWidget {
  final String message;

  const _LearningDomainNotice({required this.message});

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
