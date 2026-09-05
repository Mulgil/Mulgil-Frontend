import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/app_services.dart';
import '../../data/learning_domain_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/lecture.dart';
import '../../models/quiz_question.dart';
import '../../widgets/confirm_dialog.dart';
import 'widgets/quiz_answer_buttons.dart';
import 'widgets/quiz_result_card.dart';
import 'widgets/quiz_tablet_hint.dart';

// The actual question-by-question quiz flow for one week.
class QuizSessionScreen extends StatefulWidget {
  final String course;
  final Lecture lecture;
  final LearningDomainApi? api;

  const QuizSessionScreen({
    super.key,
    required this.course,
    required this.lecture,
    this.api,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  late final LearningDomainApi _api;
  late Future<void> _questionsLoad;
  final List<QuizQuestion> _questions = [];
  int _current = 0;
  bool _showResult = false;
  bool _submitting = false;
  bool _correct = false;
  int? _correctIndex;
  String _explanation = '';
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AppServices.learningDomain;
    _questionsLoad = _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _api.listSessionQuiz(widget.lecture.id);
      _questions
        ..clear()
        ..addAll(questions);
      _loadError = questions.isEmpty ? '퀴즈가 아직 준비되지 않았어요.' : null;
    } on ApiException catch (error) {
      _loadError = error.code == 'EMBEDDING_NOT_READY'
          ? 'AI 콘텐츠를 준비하고 있어요.'
          : error.statusCode == 409
          ? '퀴즈가 아직 준비되지 않았어요.'
          : '퀴즈를 불러오지 못했어요.';
    } on Exception {
      _loadError = '퀴즈를 불러오지 못했어요.';
    }
  }

  void _retry() {
    setState(() {
      _current = 0;
      _showResult = false;
      _correctIndex = null;
      _loadError = null;
      _questionsLoad = _loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.isTablet ? 28.0 : 20.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: FutureBuilder<void>(
            future: _questionsLoad,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final error = _loadError;
              if (error != null) {
                return _QuizSessionNotice(message: error, onRetry: _retry);
              }
              final q = _questions[_current];
              return Column(
                children: [
                  Row(
                    children: [
                      const BackIfPushed(),
                      Expanded(
                        child: Text(
                          '${widget.course} · ${widget.lecture.week}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${_current + 1} / ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink60,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _confirmQuit,
                        child: const Text(
                          '그만풀기',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.coral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MulgilProgressBar(value: (_current + 1) / _questions.length),
                  const SizedBox(height: 24),
                  if (context.isTablet)
                    _buildTabletQuiz(q)
                  else
                    _buildMobileQuiz(q),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileQuiz(QuizQuestion q) {
    final remaining = _questions.length - _current - 1;
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: MulgilCard(
              padding: const EdgeInsets.all(30),
              child: Text(
                q.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildAnswerControls(q),
          const SizedBox(height: 16),
          Text(
            '남은 문제 $remaining개 · 예상 시간 ${remaining * 30}초',
            style: const TextStyle(fontSize: 12, color: AppColors.ink60),
          ),
          const Spacer(),
          if (_showResult)
            QuizResultCard(correct: _correct, explanation: _explanation),
        ],
      ),
    );
  }

  Widget _buildTabletQuiz(QuizQuestion q) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '참고 자료',
                    style: TextStyle(fontSize: 11.5, color: AppColors.ink40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    q.sourceRefs.isEmpty
                        ? '연결된 참고 자료 없음'
                        : '참고 자료 ${q.sourceRefs.length}개',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TabletHint(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: MulgilCard(
                      padding: const EdgeInsets.all(26),
                      child: Text(
                        q.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildAnswerControls(q),
                  if (_showResult) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.yellow),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        _explanation,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.ink80,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerControls(QuizQuestion q) {
    if (q.type == QuizType.multipleChoice) {
      final options = q.options!;
      return Column(
        children: List.generate(
          options.length,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < options.length - 1 ? 10 : 0),
            child: ChoiceButton(
              index: i,
              label: options[i],
              selected: _showResult && i == _correctIndex,
              wrong: _showResult && !_correct && i != _correctIndex,
              onTap: (_showResult || _submitting) ? null : () => _answer(i, q),
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OxButton(
            label: 'O',
            color: AppColors.tealDark,
            onTap: (_showResult || _submitting) ? null : () => _answer(0, q),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: OxButton(
            label: 'X',
            color: AppColors.coral,
            onTap: (_showResult || _submitting) ? null : () => _answer(1, q),
          ),
        ),
      ],
    );
  }

  Future<void> _answer(int choice, QuizQuestion q) async {
    if (_showResult || _submitting) return;
    setState(() => _submitting = true);
    final answerValue = q.type == QuizType.trueFalse ? choice == 0 : choice;
    try {
      final result = await AppServices.learningDomain.submitQuizAttempt(
        questionId: q.id,
        answer: answerValue,
      );
      if (!mounted) return;
      setState(() {
        _correct = result.isCorrect;
        _correctIndex = q.type == QuizType.trueFalse
            ? (result.answer.value == true ? 0 : 1)
            : result.answer.value as int;
        _explanation = result.explanation.text;
        _showResult = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      if (_current + 1 >= _questions.length) {
        _finishQuiz();
        return;
      }
      setState(() {
        _current += 1;
        _showResult = false;
        _correctIndex = null;
      });
    } on ApiException catch (error) {
      _showSubmitError(error.message);
    } on Exception {
      _showSubmitError('답안을 제출하지 못했어요.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSubmitError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmQuit() async {
    final confirmed = await showMulgilConfirmDialog(
      context,
      title: '퀴즈를 그만 풀까요?',
      message: '지금까지 푼 문제는 저장되지 않아요.',
      confirmLabel: '그만풀기',
      danger: true,
    );
    if (confirmed && mounted) Navigator.of(context).pop();
  }

  Future<void> _finishQuiz() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('퀴즈 완료'),
        content: Text('${widget.lecture.week} 퀴즈를 완료하셨습니다!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _QuizSessionNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _QuizSessionNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const BackIfPushed(),
            Expanded(
              child: Text(
                '퀴즈 · $message',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  TextButton(onPressed: onRetry, child: const Text('다시 시도')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
