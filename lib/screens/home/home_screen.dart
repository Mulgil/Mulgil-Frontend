import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/lecture.dart';
import '../report/weekly_report_section.dart';
import '../../constants/routes.dart';
import 'widgets/header_icon_button.dart';
import 'widgets/notification_bell.dart';
import 'widgets/today_class_card.dart';
import 'widgets/upcoming_exams_card.dart';
import 'widgets/note_card.dart';

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
                    HeaderIconButton(
                      icon: Icons.settings_outlined,
                      onTap:
                          onOpenSettings ??
                          () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.settings),
                    ),
                    const SizedBox(width: 8),
                    const NotificationBell(),
                  ],
                ),
                const SizedBox(height: _sectionGap),
                if (todaysSlot != null) ...[
                  TodayClassCard(slot: todaysSlot),
                  const SizedBox(height: _listGap),
                ],
                const UpcomingExamsCard(),
                const SizedBox(height: _sectionGap),
                const WeeklyReportSection(),
                const SizedBox(height: _sectionGap),
                const SectionHeader(title: '최근 노트'),
                ..._recentNotes(MockData.lectures).map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: _listGap),
                    child: NoteCard(
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
