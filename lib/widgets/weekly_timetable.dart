import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/course.dart';
import '../models/timetable_slot.dart';

const _palette = [
  AppColors.teal,
  AppColors.coral,
  AppColors.navy,
  AppColors.green,
  AppColors.tealDark,
];

Color _courseColor(Course course) =>
    _palette[MockData.courses.indexOf(course) % _palette.length];

// Everytime 스타일 요일×시간 그리드. MockData.courses/timetableSlots를 그대로 그린다.
class WeeklyTimetable extends StatelessWidget {
  const WeeklyTimetable({super.key});

  static const _hourHeight = 52.0;
  static const _timeColWidth = 32.0;

  @override
  Widget build(BuildContext context) {
    final slots = MockData.timetableSlots;
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          '등록된 시간표가 없어요',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    final days = (slots.map((s) => s.weekday).toSet().toList()..sort());
    final startHour = slots.map((s) => s.startMinutes ~/ 60).reduce(min);
    final endHour = slots.map((s) => (s.endMinutes + 59) ~/ 60).reduce(max);
    final hours = List.generate(
      max(endHour - startHour, 1),
      (i) => startHour + i,
    );
    final gridHeight = hours.length * _hourHeight;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: _timeColWidth),
              ...days.map(
                (wd) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Text(
                      TimetableSlot.weekdayLabels[wd - 1],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
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
                                    color: AppColors.textLight,
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
                                (_) => Container(
                                  height: _hourHeight,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Color(0xFFF2F2F2),
                                      ),
                                      top: BorderSide(color: Color(0xFFF2F2F2)),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        ...daySlots.map((slot) {
                          final course = MockData.courses.firstWhere(
                            (c) => c.id == slot.courseId,
                          );
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _courseColor(course),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.topLeft,
                              child: Text(
                                course.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
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
