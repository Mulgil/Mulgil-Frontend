import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/lecture.dart';
import '../../models/quiz_question.dart';
import '../../widgets/confirm_dialog.dart';
import 'widgets/quiz_answer_buttons.dart';
import 'widgets/quiz_result_card.dart';
import 'widgets/quiz_tablet_hint.dart';

// The actual question-by-question quiz flow for one week — pushed from
// QuizScreen's week list (or straight from a note's "퀴즈 풀기" button).
class QuizSessionScreen extends StatefulWidget {
  final String course;
  final Lecture lecture;
  const QuizSessionScreen({
    super.key,
    required this.course,
    required this.lecture,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _current = 0;
  static const int _total = 10;
  bool _showResult = false;
  bool _submitting = false;
  bool _correct = false;
  int? _correctIndex;
  String _explanation = '';

  int get _qIdx => _current % MockData.quizQuestions.length;

  @override
  Widget build(BuildContext context) {
    final q = MockData.quizQuestions[_qIdx];
    final pad = context.isTablet ? 28.0 : 20.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: Column(
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
                    '${_current + 1} / $_total',
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
              MulgilProgressBar(value: (_current + 1) / _total),
              const SizedBox(height: 24),
              if (context.isTablet)
                _buildTabletQuiz(q)
              else
                _buildMobileQuiz(q),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileQuiz(QuizQuestion q) {
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
            '남은 문제 ${_total - _current - 1}개 · 예상 시간 ${(_total - _current - 1) * 30}초',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '참고 자료',
                    style: TextStyle(fontSize: 11.5, color: AppColors.ink40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    MockData.quizReferenceTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'SJF(Shortest Job First)는 실행 시간이 짧은 작업을 우선 처리하는 스케줄링 기법이다.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.ink80,
                      height: 1.7,
                    ),
                  ),
                  SizedBox(height: 10),
                  TabletHint(),
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
            onTap: () => _answer(0, q),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: OxButton(
            label: 'X',
            color: AppColors.coral,
            onTap: () => _answer(1, q),
          ),
        ),
      ],
    );
  }

  Future<void> _answer(int choice, QuizQuestion q) async {
    if (_showResult || _submitting) return;
    setState(() => _submitting = true);
    final answerValue = q.type == QuizType.trueFalse ? choice == 0 : choice;
    final result = await MockData.submitQuizAttempt(
      sessionId: widget.lecture.id,
      questionId: q.id,
      answer: answerValue,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _correct = result.isCorrect;
      _correctIndex = q.type == QuizType.trueFalse
          ? (result.answer.value == true ? 0 : 1)
          : result.answer.value as int;
      _explanation = result.explanation.text;
      _showResult = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (_current + 1 >= _total) {
      _finishQuiz();
      return;
    }
    setState(() {
      _current += 1;
      _showResult = false;
      _correctIndex = null;
    });
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
