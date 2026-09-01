import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import 'summary_detail_screen.dart';

class AiSummaryScreen extends StatefulWidget {
  final String? initialCourse;
  const AiSummaryScreen({super.key, this.initialCourse});

  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen> {
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
    final lectures = _courseLectures;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: lectures.isEmpty
                    ? Center(
                        child: Text(
                          '$_course 과목에는 아직 필기가 없어요',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: lectures.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final lecture = lectures[i];
                          return _SummaryWeekCard(
                            lecture: lecture,
                            onTap: lecture.done
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SummaryDetailScreen(
                                        course: _course,
                                        lecture: lecture,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryWeekCard extends StatelessWidget {
  final Lecture lecture;
  final VoidCallback? onTap;
  const _SummaryWeekCard({required this.lecture, this.onTap});

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
                    lecture.done ? '필기 완료 · AI 요약 보기' : '필기 없음 · 요약 불가',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.ink40,
                    ),
                  ),
                ],
              ),
            ),
            if (lecture.done)
              const Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: AppColors.tealDark,
              ),
          ],
        ),
      ),
    );
  }
}
