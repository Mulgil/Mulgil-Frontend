import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/exam.dart';
import 'common_widgets.dart';
import 'confirm_dialog.dart';

// Confirms with the user, then invokes onConfirmedDelete — callers still own the
// actual MockData.exams removal so they control their own setState/rebuild.
Future<void> confirmDeleteExam(
  BuildContext context,
  Exam exam,
  VoidCallback onConfirmedDelete,
) async {
  final confirmed = await showMulgilConfirmDialog(
    context,
    title: '시험을 삭제할까요?',
    message: "'${exam.courseName} · ${exam.title}' 일정과 생성된 요약·예상문제가 함께 삭제돼요.",
    confirmLabel: '삭제',
    danger: true,
  );
  if (confirmed) onConfirmedDelete();
}

// Bottom sheet for creating or editing an Exam. Pass `existingExam` to edit in place;
// omit it to create a new one. Shared by the exam management screen and settings.
class ExamFormSheet extends StatefulWidget {
  final Exam? existingExam;
  final String? initialCourseName;
  final ValueChanged<Exam> onSubmit;
  const ExamFormSheet({
    super.key,
    this.existingExam,
    this.initialCourseName,
    required this.onSubmit,
  });

  @override
  State<ExamFormSheet> createState() => _ExamFormSheetState();
}

class _ExamFormSheetState extends State<ExamFormSheet> {
  late final _titleCtrl = TextEditingController(
    text: widget.existingExam?.title ?? '',
  );
  late DateTime _examAt =
      widget.existingExam?.examAt ??
      DateTime.now().add(const Duration(days: 7));
  late String _courseName =
      widget.existingExam?.courseName ??
      widget.initialCourseName ??
      MockData.courseNames.first;
  late final Set<String> _selectedSessions = {
    ...?widget.existingExam?.sessionTitles,
  };

  bool get _isEditing => widget.existingExam != null;

  List<String> get _availableSessions =>
      MockData.lectures.map((l) => l.week).toList();

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

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _selectedSessions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시험명과 범위를 모두 입력해주세요')));
      return;
    }
    final existing = widget.existingExam;
    widget.onSubmit(
      Exam(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        courseName: _courseName,
        title: _titleCtrl.text.trim(),
        examAt: _examAt,
        sessionTitles: _selectedSessions.toList()..sort(),
        hasPastExamAttached: existing?.hasPastExamAttached ?? false,
        summaryStatus: existing?.summaryStatus ?? AiJobStatus.none,
        quizStatus: existing?.quizStatus ?? AiJobStatus.none,
      ),
    );
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
          Text(
            _isEditing ? '시험 수정' : '시험 등록',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _courseName,
            decoration: const InputDecoration(labelText: '과목'),
            items: MockData.courseNames
                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                .toList(),
            onChanged: (v) => setState(() => _courseName = v ?? _courseName),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSessions
                .map(
                  (s) => MulgilChip(
                    label: s,
                    selected: _selectedSessions.contains(s),
                    onTap: () => setState(
                      () => _selectedSessions.contains(s)
                          ? _selectedSessions.remove(s)
                          : _selectedSessions.add(s),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          MulgilButton(label: _isEditing ? '수정' : '등록', onTap: _submit),
        ],
      ),
    );
  }
}
