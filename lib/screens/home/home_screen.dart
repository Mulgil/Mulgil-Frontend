import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import '../../models/timetable_slot.dart';
import '../report/weekly_report_section.dart';

List<Lecture> _recentNotes(List<Lecture> lectures) =>
    lectures.where((l) => l.done).take(2).toList();

String _formatDate(DateTime d) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${d.year}년 ${d.month}월 ${d.day}일 ${weekdays[d.weekday - 1]}요일';
}

class HomeScreen extends StatelessWidget {
  final VoidCallback? onOpenSettings;

  const HomeScreen({super.key, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todaysSlot = MockData.todaysSlot(today);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(today),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.ink60,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('안녕하세요, 지민님', style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        onOpenSettings ??
                        () => Navigator.of(context).pushNamed('/settings'),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 14, top: 2),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  _NotificationBell(),
                ],
              ),
              const SizedBox(height: 14),
              if (todaysSlot != null) ...[
                _TodayClassCard(slot: todaysSlot),
                const SizedBox(height: 12),
              ],
              _UpcomingExamsCard(),
              const SizedBox(height: 16),
              const WeeklyReportSection(),
              const SizedBox(height: 16),
              const SectionHeader(title: '최근 노트'),
              ..._recentNotes(MockData.lectures).map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NoteCard(
                    subject: '운영체제',
                    title: '${l.week} - ${l.title}',
                    time: l.date ?? '',
                    progress: 1.0,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/note/detail', arguments: l),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final hasUnread = MockData.notifications.any((n) => !n.isRead);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/notifications'),
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
            if (hasUnread)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Shown whenever today has a timetabled class (time of day isn't checked) —
// jumps straight into a fresh note for it instead of routing through the note list.
class _TodayClassCard extends StatelessWidget {
  final TimetableSlot slot;
  const _TodayClassCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final course = MockData.courseById(slot.courseId);
    return MulgilCard(
      color: AppColors.tealSoft,
      onTap: () {
        final lecture = NotesStore.instance.createNote(
          title: '${course.name} 수업 필기',
        );
        Navigator.of(context).pushNamed('/note/detail', arguments: lecture);
      },
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 수업 · ${slot.startTime}~${slot.endTime}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text('${course.name} 필기하러 가기', style: AppTextStyles.h3),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.tealDark,
          ),
        ],
      ),
    );
  }
}

class _UpcomingExamsCard extends StatefulWidget {
  const _UpcomingExamsCard();

  @override
  State<_UpcomingExamsCard> createState() => _UpcomingExamsCardState();
}

class _UpcomingExamsCardState extends State<_UpcomingExamsCard> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exams = List.of(MockData.exams)
      ..sort((a, b) => a.examAt.compareTo(b.examAt));
    if (exams.isEmpty) return const SizedBox.shrink();
    // No onTap on the card itself — an InkWell wrapping the whole PageView
    // would fight the PageView's own drag recognizer and swallow swipes, so
    // each page gets its own tap target instead (see itemBuilder below).
    return MulgilCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '다가오는 시험일정',
                style: TextStyle(fontSize: 12, color: AppColors.ink60),
              ),
              if (exams.length > 1)
                Text(
                  '${_page + 1} / ${exams.length}',
                  style: const TextStyle(fontSize: 11, color: AppColors.ink40),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: exams.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final exam = exams[i];
                final dDay = exam.examAt.difference(DateTime.now()).inDays;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pushNamed('/exams'),
                  child: Row(
                    children: [
                      ExamDayBadge(dDay: dDay < 0 ? 0 : dDay),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${exam.courseName} · ${exam.title}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String subject, title, time;
  final double progress;
  final VoidCallback? onTap;
  const _NoteCard({
    required this.subject,
    required this.title,
    required this.time,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.ink40),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
            ),
          ),
          MulgilProgressBar(value: progress),
        ],
      ),
    );
  }
}
