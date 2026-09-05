import 'package:flutter/material.dart';

import '../../../data/notes_store.dart';
import '../../../models/lecture.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/academic_calendar.dart';
import '../../../widgets/common_widgets.dart';

class LectureCard extends StatelessWidget {
  final Lecture lecture;
  final VoidCallback? onTap;
  final bool showWeek;
  const LectureCard({
    super.key,
    required this.lecture,
    this.onTap,
    this.showWeek = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasNotes = NotesStore.instance.hasNotes(lecture);
    return MulgilCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Opacity(
        opacity: hasNotes ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  showWeek
                      ? '${lecture.week} - ${lecture.title}'
                      : lecture.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                if (showWeek &&
                    lecture.week == AcademicCalendar.currentWeekLabel()) ...[
                  const SizedBox(width: 6),
                  const CurrentWeekBadge(),
                ],
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 2, bottom: hasNotes ? 8 : 0),
              child: Text(
                hasNotes ? '${lecture.date} · 필기 완료' : '필기 없음',
                style: const TextStyle(fontSize: 11, color: AppColors.ink40),
              ),
            ),
            if (hasNotes)
              Row(
                children: [
                  if (lecture.quiz != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (lecture.stars > 0)
                    Text(
                      '⭐' * lecture.stars,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
