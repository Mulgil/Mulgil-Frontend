import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/course.dart';
import '../models/timetable_slot.dart';
import 'common_widgets.dart';
import 'confirm_dialog.dart';

// Bottom sheet for creating a Course plus one TimetableSlot per selected weekday.
// Shared by onboarding's schedule step and the settings subject manager.
class CourseFormSheet extends StatefulWidget {
  final void Function(Course course, List<TimetableSlot> slots) onAdd;
  const CourseFormSheet({super.key, required this.onAdd});

  @override
  State<CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<CourseFormSheet> {
  final _nameCtrl = TextEditingController();
  final _professorCtrl = TextEditingController();
  final Set<int> _weekdays = {}; // ISO: Monday=1 ... Sunday=7
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 15);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _professorCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // 주 1회 수업은 보통 3시간 연강, 주 2회 이상은 교시당 1시간 15분이 흔한 패턴이라 기본값으로 사용.
  // 특수한 과목은 종료 시간을 직접 눌러서 조절할 수 있음.
  int _defaultDurationMinutesFor(int weekdayCount) => weekdayCount <= 1 ? 180 : 75;

  TimeOfDay _addMinutes(TimeOfDay t, int minutes) {
    final total = (t.hour * 60 + t.minute + minutes) % (24 * 60);
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  void _autoFillEndTime() {
    _end = _addMinutes(_start, _defaultDurationMinutesFor(_weekdays.length));
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(context: context, initialTime: isStart ? _start : _end);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        _autoFillEndTime();
      } else {
        _end = picked;
      }
    });
  }

  void _toggleWeekday(int wd, bool selected) {
    setState(() {
      selected ? _weekdays.add(wd) : _weekdays.remove(wd);
      _autoFillEndTime();
    });
  }

  // Same weekday + overlapping [start,end) range against every already-registered slot.
  List<TimetableSlot> _findConflictingSlots() {
    final newStart = _start.hour * 60 + _start.minute;
    final newEnd = _end.hour * 60 + _end.minute;
    return MockData.timetableSlots.where((slot) {
      if (!_weekdays.contains(slot.weekday)) return false;
      return newStart < slot.endMinutes && newEnd > slot.startMinutes;
    }).toList();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('과목명과 요일을 입력해주세요')));
      return;
    }

    final conflicts = _findConflictingSlots();
    if (conflicts.isNotEmpty) {
      final names = conflicts.map((slot) {
        final course = MockData.courses.firstWhere((c) => c.id == slot.courseId);
        return "'${course.name}' (${slot.weekdayLabel} ${slot.startTime}~${slot.endTime})";
      }).toSet().join(', ');
      final proceed = await showMulgilConfirmDialog(
        context,
        title: '시간표가 겹쳐요',
        message: '기존 $names 시간표가 삭제되고 새 과목으로 대체돼요. 계속할까요?',
        confirmLabel: '삭제하고 추가',
        danger: true,
      );
      if (!proceed) return;
      MockData.timetableSlots.removeWhere(conflicts.contains);
    }
    if (!mounted) return;

    final courseId = 'c${DateTime.now().microsecondsSinceEpoch}';
    final course = Course(
      id: courseId,
      name: _nameCtrl.text.trim(),
      instructor: _professorCtrl.text.trim().isEmpty ? null : '${_professorCtrl.text.trim()} 교수님',
    );
    final startStr = _formatTime(_start);
    final endStr = _formatTime(_end);
    final slots = _weekdays.map((wd) => TimetableSlot(
      id: 't${DateTime.now().microsecondsSinceEpoch}_$wd',
      courseId: courseId,
      weekday: wd,
      startTime: startStr,
      endTime: endStr,
    )).toList();
    widget.onAdd(course, slots);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('과목 추가', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: '과목명', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _professorCtrl,
            decoration: InputDecoration(labelText: '교수님 (선택)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 14),
          const Text('요일', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) => i + 1).map((wd) => ChoiceChip(
              label: Text(TimetableSlot.weekdayLabels[wd - 1]),
              selected: _weekdays.contains(wd),
              onSelected: (sel) => _toggleWeekday(wd, sel),
            )).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(isStart: true),
                  child: Text('시작 ${_formatTime(_start)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(isStart: false),
                  child: Text('종료 ${_formatTime(_end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MulgilButton(label: '추가', onTap: _submit),
        ],
      ),
    );
  }
}
