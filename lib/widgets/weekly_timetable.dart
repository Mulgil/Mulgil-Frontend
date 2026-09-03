import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../data/api_client.dart';
import '../models/course.dart';
import '../models/timetable_slot.dart';
import 'confirm_dialog.dart';
import 'common_widgets.dart';
import 'course_form_sheet.dart';

const _palette = [
  AppColors.teal,
  AppColors.coral,
  AppColors.navy,
  AppColors.green,
  AppColors.tealDark,
];

Color _courseColor(Course course, List<Course> courses) {
  final index = courses.indexWhere((item) => item.id == course.id);
  return _palette[(index < 0 ? 0 : index) % _palette.length];
}

// Everytime 스타일 요일×시간 그리드. 화면은 서버에서 내려온 값만 그리고,
// 비어 있으면 비어 있는 시간표를 그대로 보여준다.
class WeeklyTimetable extends StatefulWidget {
  final List<Course>? courses;
  final List<TimetableSlot>? slots;
  final FutureOr<void> Function(Course course, List<TimetableSlot> slots)?
  onAdd;
  final FutureOr<void> Function(Course course)? onDeleteCourse;
  final VoidCallback? onChanged;
  final bool canEdit;
  // When set, tapping a course block calls this instead of the default
  // delete-confirm flow — lets a read-only context (e.g. Home) turn a tap
  // into "open this subject" navigation while course management screens
  // keep tap-to-delete.
  final void Function(Course course)? onCourseTap;
  const WeeklyTimetable({
    super.key,
    this.courses,
    this.slots,
    this.onAdd,
    this.onDeleteCourse,
    this.onChanged,
    this.canEdit = true,
    this.onCourseTap,
  });

  @override
  State<WeeklyTimetable> createState() => _WeeklyTimetableState();
}

class _WeeklyTimetableState extends State<WeeklyTimetable> {
  static const _defaultWeekdays = [1, 2, 3, 4, 5];
  static const _defaultStartHour = 9;
  static const _defaultEndHour = 16;
  static const _hourHeight = 52.0;
  static const _timeColWidth = 32.0;

  List<Course> get _courses => widget.courses ?? const [];
  List<TimetableSlot> get _slots => widget.slots ?? const [];

  Course? _courseById(List<Course> courses, String id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  Future<void> _confirmDeleteCourse(Course course) async {
    if (!widget.canEdit) return;
    final confirmed = await showMulgilConfirmDialog(
      context,
      title: '과목을 삭제할까요?',
      message: "'${course.name}' 과목과 등록된 시간표·시험 일정이 함께 삭제돼요.",
      confirmLabel: '삭제',
      danger: true,
    );
    if (!confirmed) return;
    try {
      if (widget.onDeleteCourse == null) {
        throw const ApiException(
          statusCode: 0,
          code: 'SAVE_UNAVAILABLE',
          message: '시간표 저장 연결을 확인해주세요.',
        );
      } else {
        await widget.onDeleteCourse!(course);
        if (mounted) setState(() {});
      }
      widget.onChanged?.call();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFor(error))));
    }
  }

  // weekday/startHour prefill the CourseFormSheet when opened from a tap on
  // an empty grid cell; both are null for the header's plain "+" button.
  void _openAddSheet({int? weekday, int? startHour}) {
    if (!widget.canEdit) return;
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => CourseFormSheet(
        existingSlots: _slots,
        initialWeekday: weekday,
        initialStart: startHour == null
            ? null
            : TimeOfDay(hour: startHour, minute: 0),
        onAdd: (course, slots) async {
          if (widget.onAdd == null) {
            throw const ApiException(
              statusCode: 0,
              code: 'SAVE_UNAVAILABLE',
              message: '시간표 저장 연결을 확인해주세요.',
            );
          } else {
            await widget.onAdd!(course, slots);
            if (mounted) setState(() {});
          }
          widget.onChanged?.call();
        },
      ),
    );
  }

  String _messageFor(Object error) {
    if (error is ApiException) return error.message;
    return '시간표를 저장하지 못했어요';
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    final slots = _slots;
    final days = (<int>{
      ..._defaultWeekdays,
      ...slots.map((s) => s.weekday),
    }.toList()..sort());
    // 월~금과 9~16시는 항상 보여주는 기준 범위로 고정한다. 과목을 지워도
    // 공강 요일/시간대가 사라지지 않고, 실제 수업이 기준 범위를 벗어날 때만 확장한다.
    const marginMinutes = 75;
    final actualStartHour = slots.isEmpty
        ? _defaultStartHour
        : slots.map((s) => s.startMinutes ~/ 60).reduce(min);
    final actualEndMinutes = slots.isEmpty
        ? _defaultEndHour * 60
        : slots.map((s) => s.endMinutes).reduce(max);
    final startHour = min(_defaultStartHour, actualStartHour);
    final endHour = slots.isEmpty
        ? _defaultEndHour
        : max(_defaultEndHour, (actualEndMinutes + marginMinutes + 59) ~/ 60);
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
                                  onTap: widget.canEdit
                                      ? () => _openAddSheet(
                                          weekday: wd,
                                          startHour: h,
                                        )
                                      : null,
                                  behavior: widget.canEdit
                                      ? HitTestBehavior.opaque
                                      : HitTestBehavior.deferToChild,
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
                                  (slot, _courseById(courses, slot.courseId)),
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
                                      : widget.canEdit
                                      ? () => _confirmDeleteCourse(course)
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _courseColor(course, courses),
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
