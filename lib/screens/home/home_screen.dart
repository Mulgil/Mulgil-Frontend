import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mulgil_logo.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/lecture.dart';

List<Lecture> _recentNotes(List<Lecture> lectures) =>
    lectures.where((l) => l.done).take(2).toList();

String _formatDate(DateTime d) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${d.year}년 ${d.month}월 ${d.day}일 ${weekdays[d.weekday - 1]}요일';
}

class HomeScreen extends StatelessWidget {
  // When these are supplied (i.e. the destination is also a shell tab), tapping
  // a quick action switches tabs in place instead of pushing a duplicate screen
  // that would hide the tablet sidebar / mobile bottom bar.
  final VoidCallback? onOpenNote;
  final VoidCallback? onOpenQuiz;
  final VoidCallback? onOpenSettings;

  const HomeScreen({
    super.key,
    this.onOpenNote,
    this.onOpenQuiz,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      backgroundColor: AppColors.cream,
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
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '안녕하세요, 지민님',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
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
              _StreakCard(),
              const SizedBox(height: 12),
              _UpcomingExamsCard(),
              const SizedBox(height: 14),
              _QuickActions(onOpenNote: onOpenNote, onOpenQuiz: onOpenQuiz),
              const SizedBox(height: 16),
              const SectionHeader(title: '최근 노트'),
              ..._recentNotes(MockData.lectures).map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/note/detail', arguments: l),
                    child: _NoteCard(
                      subject: '운영체제',
                      title: '${l.week} - ${l.title}',
                      time: l.date ?? '',
                      progress: 1.0,
                    ),
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

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const MulgilBubbles(size: 28),
          const SizedBox(width: 10),
          const Text(
            '12일 연속 학습 중',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
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
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/exams'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '다가오는 시험일정',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                if (exams.length > 1)
                  Text(
                    '${_page + 1} / ${exams.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
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
                  return Row(
                    children: [
                      ExamDayBadge(dDay: dDay < 0 ? 0 : dDay),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${exam.courseName} · ${exam.title}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback? onOpenNote;
  final VoidCallback? onOpenQuiz;
  const _QuickActions({this.onOpenNote, this.onOpenQuiz});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: '✎',
            label: '필기',
            route: '/note',
            onTap: onOpenNote,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: '◐',
            label: '퀴즈',
            route: '/quiz',
            onTap: onOpenQuiz,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(icon: '≡', label: '요약', route: '/summary'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(icon: '🎙', label: '녹음', route: '/recording'),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String icon, label, route;
  final VoidCallback? onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String subject, title, time;
  final double progress;
  const _NoteCard({
    required this.subject,
    required this.title,
    required this.time,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          MulgilProgressBar(value: progress),
        ],
      ),
    );
  }
}
