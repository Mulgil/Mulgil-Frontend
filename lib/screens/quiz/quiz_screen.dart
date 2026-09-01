import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import '../../models/wrong_answer.dart';
import '../review/widgets/wrong_answer_card.dart';
import '../review/widgets/wrong_answer_empty_box.dart';
import '../review/widgets/wrong_answer_stats_card.dart';
import 'quiz_session_screen.dart';

class QuizScreen extends StatefulWidget {
  final String? initialCourse;
  const QuizScreen({super.key, this.initialCourse});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late String _course = widget.initialCourse ?? MockData.courseNames.first;

  List<WrongAnswer> get _courseWrongAnswers =>
      MockData.wrongAnswers.where((w) => w.courseName == _course).toList();

  List<Lecture> get _courseLectures {
    final courseId = MockData.courseByName(_course)?.id;
    return NotesStore.instance.lectures
        .where((l) => l.courseId == courseId)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
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
              const SizedBox(height: 14),
              _buildTabBar(),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _buildQuizWeekList(context),
                    _buildWrongAnswerTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.ink60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '퀴즈'),
          Tab(text: '오답노트'),
        ],
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

  Widget _buildWrongAnswerTab(BuildContext context) {
    final answers = _courseWrongAnswers;
    final list = answers.isEmpty
        ? const WrongAnswerEmptyBox()
        : ListView.separated(
            itemCount: answers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => WrongAnswerCard(item: answers[i]),
          );

    if (context.isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: list),
          const SizedBox(width: 28),
          SizedBox(
            width: 280,
            child: Column(
              children: [
                const WrongAnswerStatsCard(),
                const SizedBox(height: 16),
                MulgilButton(
                  label: '오답만 다시 퀴즈',
                  onTap: () => _tab.animateTo(0),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(child: list),
        const SizedBox(height: 16),
        MulgilButton(label: '오답만 다시 퀴즈', onTap: () => _tab.animateTo(0)),
        const SizedBox(height: 8),
      ],
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
