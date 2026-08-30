import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/exam_form_sheet.dart';
import '../../data/mock_data.dart';
import '../../models/exam.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  String? _courseFilter;
  bool _initialized = false;
  bool _usedDailyLimit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _courseFilter = ModalRoute.of(context)?.settings.arguments as String?;
      _initialized = true;
    }
  }

  List<Exam> get _exams => _courseFilter == null
      ? MockData.exams
      : MockData.exams.where((e) => e.courseName == _courseFilter).toList();

  void _replaceExam(Exam oldExam, Exam newExam) {
    final i = MockData.exams.indexWhere((e) => e.id == oldExam.id);
    setState(() => MockData.exams[i] = newExam);
  }

  void _attachPastExam(Exam exam) {
    _replaceExam(exam, exam.copyWith(hasPastExamAttached: true));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('기출 PDF가 첨부됐어요 (mock)')));
  }

  Future<void> _generate(Exam exam, {required bool isSummary}) async {
    final current = isSummary ? exam.summaryStatus : exam.quizStatus;
    if (current == AiJobStatus.succeeded && !_usedDailyLimit) {
      setState(() => _usedDailyLimit = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘 AI 생성 한도를 모두 사용했어요 (429 AI_DAILY_LIMIT_REACHED)'),
        ),
      );
      return;
    }
    if (!exam.hasPastExamAttached && !isSummary) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예상 문제를 만들려면 기출 PDF를 먼저 첨부해주세요')),
      );
      return;
    }
    _replaceExam(
      exam,
      isSummary
          ? exam.copyWith(summaryStatus: AiJobStatus.running)
          : exam.copyWith(quizStatus: AiJobStatus.running),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final running = MockData.exams.firstWhere((e) => e.id == exam.id);
    _replaceExam(
      running,
      isSummary
          ? running.copyWith(summaryStatus: AiJobStatus.succeeded)
          : running.copyWith(quizStatus: AiJobStatus.succeeded),
    );
  }

  void _openCreateSheet() {
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => ExamFormSheet(
        initialCourseName: _courseFilter,
        onSubmit: (exam) => setState(() => MockData.exams.insert(0, exam)),
      ),
    );
  }

  void _openEditSheet(Exam exam) {
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => ExamFormSheet(
        existingExam: exam,
        onSubmit: (updated) => _replaceExam(exam, updated),
      ),
    );
  }

  void _deleteExam(Exam exam) {
    confirmDeleteExam(context, exam, () {
      setState(() => MockData.exams.removeWhere((e) => e.id == exam.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _courseFilter == null
                          ? '시험 관리'
                          : '시험 관리 · $_courseFilter',
                      style: AppTextStyles.h2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _exams.isEmpty
                    ? const Center(
                        child: Text(
                          '등록된 시험이 없어요',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _exams.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _ExamCard(
                          exam: _exams[i],
                          onAttachPastExam: () => _attachPastExam(_exams[i]),
                          onGenerateSummary: () =>
                              _generate(_exams[i], isSummary: true),
                          onGenerateQuiz: () =>
                              _generate(_exams[i], isSummary: false),
                          onEdit: () => _openEditSheet(_exams[i]),
                          onDelete: () => _deleteExam(_exams[i]),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ExamCard({
    required this.exam,
    required this.onAttachPastExam,
    required this.onGenerateSummary,
    required this.onGenerateQuiz,
    required this.onEdit,
    required this.onDelete,
  });

  int get _dDay => exam.examAt.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExamDayBadge(dDay: _dDay < 0 ? 0 : _dDay),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.courseName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      exam.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textLight,
                ),
                padding: EdgeInsets.zero,
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: exam.sessionTitles
                .map((s) => MulgilChip(label: s))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: exam.hasPastExamAttached ? null : onAttachPastExam,
                  icon: Icon(
                    exam.hasPastExamAttached ? Icons.check : Icons.upload_file,
                    size: 16,
                  ),
                  label: Text(
                    exam.hasPastExamAttached ? '기출 첨부됨' : '기출 PDF 첨부',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.navy),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _JobButton(
                  label: '요약 생성',
                  status: exam.summaryStatus,
                  onTap: onGenerateSummary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _JobButton(
                  label: '예상 문제 생성',
                  status: exam.quizStatus,
                  onTap: onGenerateQuiz,
                ),
              ),
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
  const _JobButton({
    required this.label,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning =
        status == AiJobStatus.queued || status == AiJobStatus.running;
    final isFailed = status == AiJobStatus.failed;
    final isDone = status == AiJobStatus.succeeded;

    final bg = isFailed
        ? AppColors.coralSoft
        : (isDone ? AppColors.tealSoft : AppColors.chip);
    final fg = isFailed
        ? AppColors.coral
        : (isDone ? AppColors.tealDark : AppColors.textPrimary);
    final text = isRunning
        ? '생성 중...'
        : (isFailed ? '실패 · 재시도' : (isDone ? '$label 완료 · 보기' : label));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: isRunning ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: isRunning
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
