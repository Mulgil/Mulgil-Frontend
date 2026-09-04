import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../data/api_client.dart';
import '../models/course.dart';
import '../models/timetable_slot.dart';
import 'common_widgets.dart';

part 'course_form_sheet_view.dart';

// Bottom sheet for creating a Course plus independently timed slots per weekday.
// Shared by onboarding's schedule step and the settings subject manager.
class CourseFormSheet extends StatefulWidget {
  final FutureOr<void> Function(Course course, List<TimetableSlot> slots) onAdd;
  final List<TimetableSlot>? existingSlots;
  final int? initialWeekday;
  final TimeOfDay? initialStart;
  const CourseFormSheet({
    super.key,
    required this.onAdd,
    this.existingSlots,
    this.initialWeekday,
    this.initialStart,
  });

  @override
  State<CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<CourseFormSheet> {
  final _nameCtrl = TextEditingController();
  final _professorCtrl = TextEditingController();
  final Map<int, ({TimeOfDay start, TimeOfDay end})> _timesByWeekday = {};
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initialWeekday = widget.initialWeekday;
    if (initialWeekday != null) _timesByWeekday[initialWeekday] = _newTime();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _professorCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // 주 1회 수업은 보통 3시간 연강, 주 2회 이상은 교시당 1시간 15분이 흔한 패턴이라 기본값으로 사용.
  // 특수한 과목은 종료 시간을 직접 눌러서 조절할 수 있음.
  int _defaultDurationMinutesFor(int weekdayCount) =>
      weekdayCount <= 1 ? 180 : 75;

  TimeOfDay _addMinutes(TimeOfDay t, int minutes) {
    final total = (t.hour * 60 + t.minute + minutes) % (24 * 60);
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  ({TimeOfDay start, TimeOfDay end}) _newTime() {
    final start = _timesByWeekday.isEmpty
        ? widget.initialStart ?? const TimeOfDay(hour: 9, minute: 0)
        : _timesByWeekday.values.first.start;
    return (
      start: start,
      end: _addMinutes(
        start,
        _defaultDurationMinutesFor(_timesByWeekday.length + 1),
      ),
    );
  }

  Future<void> _pickTime(int weekday, {required bool isStart}) async {
    final time = _timesByWeekday[weekday];
    if (time == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? time.start : time.end,
    );
    if (picked == null || !mounted) return;
    if (!isStart && _toMinutes(picked) <= _toMinutes(time.start)) {
      setState(() => _errorText = '종료 시간은 시작 시간보다 늦어야 해요');
      return;
    }
    setState(() {
      _errorText = null;
      _timesByWeekday[weekday] = isStart
          ? (
              start: picked,
              end: _addMinutes(
                picked,
                _defaultDurationMinutesFor(_timesByWeekday.length),
              ),
            )
          : (start: time.start, end: picked);
    });
  }

  void _toggleWeekday(int wd, bool selected) {
    setState(() {
      _errorText = null;
      if (selected) {
        _timesByWeekday[wd] = _newTime();
      } else {
        _timesByWeekday.remove(wd);
      }
    });
  }

  bool _hasConflictingSlot() => _timesByWeekday.entries.any(
    (entry) => (widget.existingSlots ?? const <TimetableSlot>[]).any(
      (slot) =>
          slot.weekday == entry.key &&
          _toMinutes(entry.value.start) < slot.endMinutes &&
          _toMinutes(entry.value.end) > slot.startMinutes,
    ),
  );

  List<MapEntry<int, ({TimeOfDay start, TimeOfDay end})>> get _timeEntries =>
      _timesByWeekday.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  void _clearError() {
    if (_errorText != null) setState(() => _errorText = null);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _errorText = null);

    if (_nameCtrl.text.trim().isEmpty || _timesByWeekday.isEmpty) {
      setState(() => _errorText = '과목명과 요일을 입력해주세요');
      return;
    }

    if (_hasConflictingSlot()) {
      setState(() => _errorText = '기존 시간표와 겹쳐서 추가할 수 없어요');
      return;
    }
    if (!mounted) return;

    final courseId = 'c${DateTime.now().microsecondsSinceEpoch}';
    final course = Course(
      id: courseId,
      name: _nameCtrl.text.trim(),
      instructor: _professorCtrl.text.trim().isEmpty
          ? null
          : '${_professorCtrl.text.trim()} 교수님',
    );
    final slots = _timeEntries
        .map(
          (entry) => TimetableSlot(
            id: 't${DateTime.now().microsecondsSinceEpoch}_${entry.key}',
            courseId: courseId,
            weekday: entry.key,
            startTime: _formatTime(entry.value.start),
            endTime: _formatTime(entry.value.end),
          ),
        )
        .toList();
    setState(() => _submitting = true);
    try {
      await widget.onAdd(course, slots);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = _messageFor(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _messageFor(Object error) {
    if (error is ApiException) return error.message;
    return '과목을 저장하지 못했어요';
  }

  @override
  Widget build(BuildContext context) => _buildForm(context);
}
