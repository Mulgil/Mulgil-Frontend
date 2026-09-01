import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../data/mock_data.dart';
import '../../../data/notes_store.dart';
import '../../../models/timetable_slot.dart';
import '../../../constants/routes.dart';

// Shown whenever today has a timetabled class (time of day isn't checked) —
// jumps straight into a fresh note for it instead of routing through the note list.
class TodayClassCard extends StatelessWidget {
  final TimetableSlot slot;
  const TodayClassCard({super.key, required this.slot});

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
