import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../models/course.dart';
import '../../../models/exam.dart';

// Bottom sheet for setting a course's exam name + date during onboarding.
// Deliberately lighter than ExamFormSheet — no session-range picker, since
// onboarding runs before any lecture notes exist to pick a range from.
class ExamQuickSheet extends StatefulWidget {
  final Course course;
  final Exam? existing;
  const ExamQuickSheet({
    super.key,
    required this.course,
    required this.existing,
  });

  @override
  State<ExamQuickSheet> createState() => _ExamQuickSheetState();
}

class _ExamQuickSheetState extends State<ExamQuickSheet> {
  static const _presets = ['중간고사', '기말고사', '퀴즈'];

  late final _titleCtrl = TextEditingController(
    text: widget.existing?.title ?? _presets.first,
  );
  late DateTime _examAt =
      widget.existing?.examAt ?? DateTime.now().add(const Duration(days: 14));

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
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시험 이름을 입력해주세요')));
      return;
    }
    final existing = widget.existing;
    Navigator.pop(
      context,
      Exam(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        courseName: widget.course.name,
        title: title,
        examAt: _examAt,
        sessionTitles: existing?.sessionTitles ?? const [],
        hasPastExamAttached: existing?.hasPastExamAttached ?? false,
        summaryStatus: existing?.summaryStatus ?? AiJobStatus.none,
        quizStatus: existing?.quizStatus ?? AiJobStatus.none,
      ),
    );
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
            '${widget.course.name} 시험 일정',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _presets
                .map(
                  (p) => MulgilChip(
                    label: p,
                    selected: _titleCtrl.text == p,
                    onTap: () => setState(() => _titleCtrl.text = p),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: '시험명',
              hintText: '예: 중간고사',
            ),
            onChanged: (_) => setState(() {}),
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
          const SizedBox(height: 20),
          MulgilButton(
            label: widget.existing == null ? '등록' : '수정',
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}
