import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/course.dart';
import '../models/timetable_slot.dart';
import 'common_widgets.dart';

// Bottom sheet for creating a Course plus one TimetableSlot per selected weekday.
// Shared by onboarding's schedule step and the settings subject manager.
class CourseFormSheet extends StatefulWidget {
  final void Function(Course course, List<TimetableSlot> slots) onAdd;
  final int? initialWeekday;
  final TimeOfDay? initialStart;
  const CourseFormSheet({
    super.key,
    required this.onAdd,
    this.initialWeekday,
    this.initialStart,
  });

  @override
  State<CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<CourseFormSheet> {
  final _nameCtrl = TextEditingController();
  final _professorCtrl = TextEditingController();
  final Set<int> _weekdays = {}; // ISO: Monday=1 ... Sunday=7
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    if (widget.initialWeekday != null) _weekdays.add(widget.initialWeekday!);
    _start = widget.initialStart ?? const TimeOfDay(hour: 9, minute: 0);
    _end = _addMinutes(_start, _defaultDurationMinutesFor(_weekdays.length));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _professorCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // 雅?1????뤿씜?? 癰귣똾??3??볦퍢 ?怨뚯뺏, 雅?2????곴맒?? ?대Ŋ???1??볦퍢 15?브쑴???酉釉????쉘????疫꿸퀡??첎誘れ몵嚥?????
  // ?諭????⑥눖??? ?ル굝利???볦퍢??筌욊낯?????쑎??鈺곌퀣???????됱벉.
  int _defaultDurationMinutesFor(int weekdayCount) =>
      weekdayCount <= 1 ? 180 : 75;

  TimeOfDay _addMinutes(TimeOfDay t, int minutes) {
    final total = (t.hour * 60 + t.minute + minutes) % (24 * 60);
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  void _autoFillEndTime() {
    _end = _addMinutes(_start, _defaultDurationMinutesFor(_weekdays.length));
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null || !mounted) return;
    if (!isStart && _toMinutes(picked) <= _toMinutes(_start)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('?ル굝利???볦퍢?? ??뽰삂 ??볦퍢癰귣?????堉????곸뒄')));
      return;
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('?⑥눖?됵쭗?껊궢 ?遺우뵬????낆젾??곻폒?紐꾩뒄')));
      return;
    }

    final conflicts = _findConflictingSlots();
    if (conflicts.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A timetable conflict cannot replace an existing course.')),
      );
      return;
    }
    if (!mounted) return;

    final courseId = 'c${DateTime.now().microsecondsSinceEpoch}';
    final course = Course(
      id: courseId,
      name: _nameCtrl.text.trim(),
      instructor: _professorCtrl.text.trim().isEmpty
          ? null
          : '${_professorCtrl.text.trim()} ?대Ŋ???,
    );
    final startStr = _formatTime(_start);
    final endStr = _formatTime(_end);
    final slots = _weekdays
        .map(
          (wd) => TimetableSlot(
            id: 't${DateTime.now().microsecondsSinceEpoch}_$wd',
            courseId: courseId,
            weekday: wd,
            startTime: startStr,
            endTime: endStr,
          ),
        )
        .toList();
    widget.onAdd(course, slots);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '?⑥눖???곕떽?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '?⑥눖?됵쭗?),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _professorCtrl,
            decoration: const InputDecoration(labelText: '?대Ŋ???(?醫뤾문)'),
          ),
          const SizedBox(height: 14),
          const Text(
            '?遺우뵬',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) => i + 1)
                .map(
                  (wd) => ChoiceChip(
                    label: Text(TimetableSlot.weekdayLabels[wd - 1]),
                    selected: _weekdays.contains(wd),
                    onSelected: (sel) => _toggleWeekday(wd, sel),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(isStart: true),
                  child: Text('??뽰삂 ${_formatTime(_start)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(isStart: false),
                  child: Text('?ル굝利?${_formatTime(_end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MulgilButton(label: '?곕떽?', onTap: _submit),
        ],
      ),
    );
  }
}
