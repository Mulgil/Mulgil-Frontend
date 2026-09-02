import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/course.dart';
import '../models/timetable_slot.dart';
import 'common_widgets.dart';
import 'course_form_sheet.dart';

const _palette = [
  AppColors.teal,
  AppColors.coral,
  AppColors.navy,
  AppColors.green,
  AppColors.tealDark,
];

Color _courseColor(Course course) =>
    _palette[MockData.courses.indexOf(course) % _palette.length];

// Everytime ??????遺우뵬???볦퍢 域밸챶??? MockData.courses/timetableSlots??域밸챶?嚥?域밸챶???
// Owns its own add/delete flow (tap a block -> confirm -> remove; tap an
// empty cell or the "+" -> add) so every screen that embeds this gets it for
// free without threading a callback through. MockData is plain mutable state
// (not a ChangeNotifier), so any screen that also renders something derived
// from it (e.g. an exam list keyed by course) must pass `onChanged` and
// rebuild itself there ??otherwise it'll show stale data after this widget's
// own setState mutates the shared lists out from under it.
class WeeklyTimetable extends StatefulWidget {
  final VoidCallback? onChanged;
  // When set, tapping a course block calls this instead of the default
  // delete-confirm flow ??lets a read-only context (e.g. Home) turn a tap
  // into "open this subject" navigation while course management screens
  // keep tap-to-delete.
  final void Function(Course course)? onCourseTap;
  const WeeklyTimetable({super.key, this.onChanged, this.onCourseTap});

  @override
  State<WeeklyTimetable> createState() => _WeeklyTimetableState();
}

class _WeeklyTimetableState extends State<WeeklyTimetable> {
  static const _hourHeight = 52.0;
  static const _timeColWidth = 32.0;

  Future<void> _confirmDeleteCourse(Course course) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course deletion is not supported by the server.')),
    );
  }

  // weekday/startHour prefill the CourseFormSheet when opened from a tap on
  // an empty grid cell; both are null for the header's plain "+" button.
  void _openAddSheet({int? weekday, int? startHour}) {
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => CourseFormSheet(
        initialWeekday: weekday,
        initialStart: startHour == null
            ? null
            : TimeOfDay(hour: startHour, minute: 0),
        onAdd: (course, slots) {
          setState(() {
            MockData.courses.add(course);
            MockData.timetableSlots.addAll(slots);
          });
          widget.onChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = MockData.timetableSlots;
    if (slots.isEmpty) {
      return GestureDetector(
        onTap: () => _openAddSheet(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Text(
            '+ ???쑎????볦퍢??? ?源낆쨯??곻폒?紐꾩뒄',
            style: TextStyle(color: AppColors.ink60, fontSize: 13),
          ),
        ),
      );
    }

    final days = (slots.map((s) => s.weekday).toSet().toList()..sort());
    // 9~16??? ??湲?癰귣똻肉т틠?곕뮉 疫꿸퀣? 甕곕뗄?욄에??⑥쥙?????⑥눖???筌왖?怨뚭탢????? ??볦퍢?? ??뤿씜????곷선??域밸챶????
    // 揶쏅쵐?꾣묾?餓κ쑴堉??쇰선 癰귣똻?좑쭪? ??낅즲嚥? ??쇱젫 ??뤿씜????甕곕뗄?욅몴?甕곗щ선??롢늺 域밸챶彛?? 域밸챶?곫?揶쎛????苡???멸돌??    // ??뤿씜 ?袁⑥삋嚥?1??볦퍢 15?브쑴????媛???곕떽?嚥?癰귣똻肉т빳???
    const marginMinutes = 75;
    final actualStartHour = slots.map((s) => s.startMinutes ~/ 60).reduce(min);
    final actualEndMinutes = slots.map((s) => s.endMinutes).reduce(max);
    final startHour = min(9, actualStartHour);
    final endHour = max(16, (actualEndMinutes + marginMinutes + 59) ~/ 60);
    final hours = List.generate(
      max(endHour - startHour, 1),
      (i) => startHour + i,
    );
    final gridHeight = hours.length * _hourHeight;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: _timeColWidth),
              ...days.map(
                (wd) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Text(
                      TimetableSlot.weekdayLabels[wd - 1],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: gridHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _timeColWidth,
                  child: Column(
                    children: hours
                        .map(
                          (h) => SizedBox(
                            height: _hourHeight,
                            child: Transform.translate(
                              offset: const Offset(0, -6),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  '$h',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.ink40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                ...days.map((wd) {
                  final daySlots = slots.where((s) => s.weekday == wd);
                  return Expanded(
                    child: Stack(
                      children: [
                        Column(
                          children: hours
                              .map(
                                (h) => GestureDetector(
                                  onTap: () =>
                                      _openAddSheet(weekday: wd, startHour: h),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    height: _hourHeight,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: AppColors.border,
                                        ),
                                        top: BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        ...daySlots
                            .map(
                              (slot) =>
                                  (slot, MockData.courseById(slot.courseId)),
                            )
                            .where((pair) => pair.$2 != null)
                            .map((pair) {
                              final slot = pair.$1;
                              final course = pair.$2!;
                              final top =
                                  (slot.startMinutes - startHour * 60) /
                                  60 *
                                  _hourHeight;
                              final height =
                                  (slot.endMinutes - slot.startMinutes) /
                                  60 *
                                  _hourHeight;
                              return Positioned(
                                top: top + 1,
                                left: 2,
                                right: 2,
                                height: max(height - 2, 0),
                                child: GestureDetector(
                                  onTap: widget.onCourseTap != null
                                      ? () => widget.onCourseTap!(course)
                                      : () => _confirmDeleteCourse(course),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _courseColor(course),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (course.instructor != null)
                                          Text(
                                            course.instructor!,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white70,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
