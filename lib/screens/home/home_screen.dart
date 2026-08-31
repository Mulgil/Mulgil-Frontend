import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import '../../models/timetable_slot.dart';
import '../report/weekly_report_section.dart';
import '../../constants/routes.dart';

List<Lecture> _recentNotes(List<Lecture> lectures) =>
    lectures.where((l) => l.done).take(2).toList();

String _formatDate(DateTime d) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${d.year}년 ${d.month}월 ${d.day}일 ${weekdays[d.weekday - 1]}요일';
}

class HomeScreen extends StatelessWidget {
  final VoidCallback? onOpenSettings;

  const HomeScreen({super.key, this.onOpenSettings});

  // Vertical rhythm for the screen's top-level sections — was a mix of
  // 12/14/16 picked ad hoc per gap, which read as slightly cramped and
  // inconsistent. One value here, one tighter value for within-section lists.
  static const _sectionGap = 24.0;
  static const _listGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todaysSlot = MockData.todaysSlot(today);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: MaxContentWidth(
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
                            _formatDate(today),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink60,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '안녕하세요, ${MockData.currentUser.name}님',
                            style: AppTextStyles.h1,
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      icon: Icons.settings_outlined,
                      onTap:
                          onOpenSettings ??
                          () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.settings),
                    ),
                    const SizedBox(width: 8),
                    const _NotificationBell(),
                  ],
                ),
                const SizedBox(height: _sectionGap),
                if (todaysSlot != null) ...[
                  _TodayClassCard(slot: todaysSlot),
                  const SizedBox(height: _listGap),
                ],
                _UpcomingExamsCard(),
                const SizedBox(height: _sectionGap),
                const WeeklyReportSection(),
                const SizedBox(height: _sectionGap),
                const SectionHeader(title: '최근 노트'),
                ..._recentNotes(MockData.lectures).map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: _listGap),
                    child: _NoteCard(
                      subject:
                          MockData.courseById(l.courseId)?.name ?? '알 수 없는 과목',
                      title: '${l.week} - ${l.title}',
                      time: l.date ?? '',
                      progress: 1.0,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.noteDetail, arguments: l),
                    ),
                  ),
                ),
                const SizedBox(height: _sectionGap - 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bordered circular tap target for header actions — matches MulgilCard's flat
// bordered language instead of a bare floating Icon with hand-tuned padding.
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
        if (hasUnread)
          Positioned(
            right: 1,
            top: 1,
            child: IgnorePointer(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
                ),
              ),
            ),
          ),
      ],
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
    if (course == null) return const SizedBox.shrink();
    return MulgilCard(
      color: AppColors.tealSoft,
      onTap: () {
        final lecture = NotesStore.instance.createNote(
          title: '${course.name} 수업 필기',
          courseId: course.id,
        );
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.noteDetail, arguments: lecture);
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
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.exams),
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
          const SizedBox(height: 6),
          Text(title, style: AppTextStyles.body),
          const SizedBox(height: 8),
          MulgilProgressBar(value: progress),
        ],
      ),
    );
  }
}
