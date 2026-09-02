import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import 'quiz_session_screen.dart';

class QuizScreen extends StatefulWidget {
  final String? initialCourse;
  const QuizScreen({super.key, this.initialCourse});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late String _course = widget.initialCourse ?? MockData.courseNames.first;

  List<Lecture> get _courseLectures {
    final courseId = MockData.courseByName(_course)?.id;
    return NotesStore.instance.lectures
        .where((l) => l.courseId == courseId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.isTablet ? 28.0 : 20.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: Column(
            children: [
              Row(
                children: [
                  const BackIfPushed(),
                  CourseDropdown(
                    selected: _course,
                    options: MockData.courseNames,
                    onChanged: (v) => setState(() => _course = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildQuizWeekList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizWeekList(BuildContext context) {
    final lectures = _courseLectures;
    if (lectures.isEmpty) {
      return Center(
        child: Text(
          '$_course 과목에는 아직 필기가 없어요',
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
          onTap: lecture.done
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizSessionScreen(course: _course, lecture: lecture),
                  ),
                )
              : null,
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
      child: Opacity(
        opacity: lecture.done ? 1.0 : 0.5,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${lecture.week} - ${lecture.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      if (lecture.week == MockData.currentWeekLabel) ...[
                        const SizedBox(width: 6),
                        const CurrentWeekBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lecture.done ? '필기 완료' : '필기 없음 · 퀴즈 불가',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.ink40,
                    ),
                  ),
                ],
              ),
            ),
            if (lecture.quiz != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '퀴즈 ${lecture.quiz}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.tealDark,
                  ),
                ),
              )
            else if (lecture.done)
              const Icon(Icons.chevron_right, size: 20, color: AppColors.ink40),
          ],
        ),
      ),
    );
  }
}
