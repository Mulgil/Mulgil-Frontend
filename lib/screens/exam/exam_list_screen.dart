import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/exam.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  String? _courseFilter;
  late List<Exam> _exams;
  bool _initialized = false;
  bool _usedDailyLimit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _courseFilter = ModalRoute.of(context)?.settings.arguments as String?;
      _exams = _courseFilter == null
          ? List.of(MockData.exams)
          : MockData.exams.where((e) => e.courseName == _courseFilter).toList();
      _initialized = true;
    }
  }

  void _attachPastExam(Exam exam) {
    final i = _exams.indexOf(exam);
    setState(() => _exams[i] = exam.copyWith(hasPastExamAttached: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('기출 PDF가 첨부됐어요 (mock)')));
  }

  Future<void> _generate(Exam exam, {required bool isSummary}) async {
    final current = isSummary ? exam.summaryStatus : exam.quizStatus;
    if (current == AiJobStatus.succeeded && !_usedDailyLimit) {
      setState(() => _usedDailyLimit = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 AI 생성 한도를 모두 사용했어요 (429 AI_DAILY_LIMIT_REACHED)')),
      );
      return;
    }
    if (!exam.hasPastExamAttached && !isSummary) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예상 문제를 만들려면 기출 PDF를 먼저 첨부해주세요')),
      );
      return;
    }
    final i = _exams.indexOf(exam);
    setState(() => _exams[i] = isSummary ? exam.copyWith(summaryStatus: AiJobStatus.running) : exam.copyWith(quizStatus: AiJobStatus.running));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _exams[i] = isSummary ? _exams[i].copyWith(summaryStatus: AiJobStatus.succeeded) : _exams[i].copyWith(quizStatus: AiJobStatus.succeeded));
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ExamCreateSheet(
        courseName: _courseFilter ?? MockData.courseNames.first,
        onCreate: (exam) => setState(() => _exams = [exam, ..._exams]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _courseFilter == null ? '시험 관리' : '시험 관리 · $_courseFilter',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _exams.isEmpty
                    ? const Center(child: Text('등록된 시험이 없어요', style: TextStyle(color: AppColors.textMuted)))
                    : ListView.separated(
                        itemCount: _exams.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _ExamCard(
                          exam: _exams[i],
                          onAttachPastExam: () => _attachPastExam(_exams[i]),
                          onGenerateSummary: () => _generate(_exams[i], isSummary: true),
                          onGenerateQuiz: () => _generate(_exams[i], isSummary: false),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              MulgilButton(label: '+ 시험 등록', onTap: _openCreateSheet),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onAttachPastExam;
  final VoidCallback onGenerateSummary;
  final VoidCallback onGenerateQuiz;
  const _ExamCard({
    required this.exam,
    required this.onAttachPastExam,
    required this.onGenerateSummary,
    required this.onGenerateQuiz,
  });

  int get _dDay => exam.examAt.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exam.courseName, style: const TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w700)),
                  Text(exam.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
              ExamDayBadge(dDay: _dDay < 0 ? 0 : _dDay),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: exam.sessionTitles.map((s) => MulgilChip(label: s)).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: exam.hasPastExamAttached ? null : onAttachPastExam,
                  icon: Icon(exam.hasPastExamAttached ? Icons.check : Icons.upload_file, size: 16),
                  label: Text(exam.hasPastExamAttached ? '기출 첨부됨' : '기출 PDF 첨부', style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.navy, side: const BorderSide(color: AppColors.navy)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _JobButton(label: '요약 생성', status: exam.summaryStatus, onTap: onGenerateSummary)),
              const SizedBox(width: 8),
              Expanded(child: _JobButton(label: '예상 문제 생성', status: exam.quizStatus, onTap: onGenerateQuiz)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '※ 첨부된 기출을 바탕으로 한 예상일 뿐, 실제 기출 제공이나 적중을 보장하지 않아요',
            style: TextStyle(fontSize: 10.5, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _JobButton extends StatelessWidget {
  final String label;
  final AiJobStatus status;
  final VoidCallback onTap;
  const _JobButton({required this.label, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRunning = status == AiJobStatus.queued || status == AiJobStatus.running;
    final isFailed = status == AiJobStatus.failed;
    final isDone = status == AiJobStatus.succeeded;

    final bg = isFailed ? const Color(0xFFFFF0EB) : (isDone ? const Color(0xFFEEF7F8) : const Color(0xFFF2F2F2));
    final fg = isFailed ? AppColors.coral : (isDone ? AppColors.tealDark : AppColors.textPrimary);
    final text = isRunning ? '생성 중...' : (isFailed ? '실패 · 재시도' : (isDone ? '$label 완료 · 보기' : label));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isRunning ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: isRunning
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(text, style: TextStyle(fontSize: 11.5, color: fg, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _ExamCreateSheet extends StatefulWidget {
  final String courseName;
  final ValueChanged<Exam> onCreate;
  const _ExamCreateSheet({required this.courseName, required this.onCreate});

  @override
  State<_ExamCreateSheet> createState() => _ExamCreateSheetState();
}

class _ExamCreateSheetState extends State<_ExamCreateSheet> {
  final _titleCtrl = TextEditingController();
  DateTime _examAt = DateTime.now().add(const Duration(days: 7));
  final Set<String> _selectedSessions = {};

  static final _availableSessions = MockData.lectures.map((l) => l.week).toList();

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('시험명과 범위를 모두 입력해주세요')));
      return;
    }
    widget.onCreate(Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseName: widget.courseName,
      title: _titleCtrl.text.trim(),
      examAt: _examAt,
      sessionTitles: _selectedSessions.toList()..sort(),
    ));
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
          const Text('시험 등록', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: '시험명',
              hintText: '예: 중간고사',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('시험 날짜', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  Text('${_examAt.year}.${_examAt.month}.${_examAt.day}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('시험 범위', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSessions.map((s) => MulgilChip(
              label: s,
              selected: _selectedSessions.contains(s),
              onTap: () => setState(() => _selectedSessions.contains(s) ? _selectedSessions.remove(s) : _selectedSessions.add(s)),
            )).toList(),
          ),
          const SizedBox(height: 20),
          MulgilButton(label: '등록', onTap: _submit),
        ],
      ),
    );
  }
}
