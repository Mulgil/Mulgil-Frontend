import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/lecture.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

Future<void> confirmDeleteExam(
  BuildContext context,
  Exam _,
  VoidCallback _,
) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Exam deletion is not supported by the server.'),
    ),
  );
}

typedef ExamCreateCallback = Future<void> Function({
  required Course course,
  required String title,
  required DateTime examAt,
  required List<Lecture> sessions,
});

class ExamFormSheet extends StatefulWidget {
  final Course? initialCourse;
  final List<Course> courses;
  final List<Lecture> sessions;
  final ExamCreateCallback onCreate;

  const ExamFormSheet({
    super.key,
    this.initialCourse,
    required this.courses,
    required this.sessions,
    required this.onCreate,
  });

  @override
  State<ExamFormSheet> createState() => _ExamFormSheetState();
}

class _ExamFormSheetState extends State<ExamFormSheet> {
  late final _titleCtrl = TextEditingController();
  late DateTime _examAt = DateTime.now().add(const Duration(days: 7));
  late String? _courseId = _initialCourseId();
  final Set<String> _selectedSessionIds = {};
  bool _isSubmitting = false;

  String? _initialCourseId() {
    final initialCourse = widget.initialCourse;
    if (initialCourse != null &&
        widget.courses.any((course) => course.id == initialCourse.id)) {
      return initialCourse.id;
    }
    return widget.courses.isEmpty ? null : widget.courses.first.id;
  }

  Course? get _selectedCourse {
    final courseId = _courseId;
    if (courseId == null) return null;
    for (final course in widget.courses) {
      if (course.id == courseId) return course;
    }
    return null;
  }

  List<Lecture> get _availableSessions {
    final courseId = _courseId;
    if (courseId == null) return const [];
    return widget.sessions
        .where((session) => session.courseId == courseId)
        .toList();
  }

  String _sessionLabel(Lecture session) {
    final date = session.date;
    final base = '${session.week} · ${session.title}';
    return date == null ? base : '$base ($date)';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _examAt = picked);
  }

  Future<void> _submit() async {
    final course = _selectedCourse;
    final sessions = _availableSessions
        .where((session) => _selectedSessionIds.contains(session.id))
        .toList();
    if (course == null || _titleCtrl.text.trim().isEmpty || sessions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('과목, 시험명, 범위를 모두 입력해주세요')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onCreate(
        course: course,
        title: _titleCtrl.text.trim(),
        examAt: _examAt,
        sessions: sessions,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시험 일정을 저장하지 못했어요. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
              '시험 등록',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCourse == null ? null : _courseId,
              decoration: const InputDecoration(labelText: '과목'),
              items: widget.courses
                  .map(
                    (course) => DropdownMenuItem(
                      value: course.id,
                      child: Text(course.name),
                    ),
                  )
                  .toList(),
              onChanged: (courseId) => setState(() {
                _courseId = courseId;
                _selectedSessionIds.clear();
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: '시험명',
                hintText: '예: 중간고사',
              ),
            ),
            const SizedBox(height: 14),
            MulgilCard(
              onTap: _pickDate,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '시험 날짜',
                    style: TextStyle(fontSize: 13, color: AppColors.ink60),
                  ),
                  Text(
                    '${_examAt.year}.${_examAt.month}.${_examAt.day}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '시험 범위',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            if (_availableSessions.isEmpty)
              const Text(
                '선택한 과목에 등록된 차시가 없어요. 시간표를 먼저 등록해주세요.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSessions
                    .map(
                      (session) => MulgilChip(
                        label: _sessionLabel(session),
                        selected: _selectedSessionIds.contains(session.id),
                        onTap: () => setState(
                          () => _selectedSessionIds.contains(session.id)
                              ? _selectedSessionIds.remove(session.id)
                              : _selectedSessionIds.add(session.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 20),
            MulgilButton(
              label: _isSubmitting ? '등록 중...' : '등록',
              onTap: _isSubmitting ? null : () => _submit(),
            ),
          ],
        ),
      ),
    );
  }
}
