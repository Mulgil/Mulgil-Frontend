import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _current = 3;
  static const int _total = 10;
  bool _showResult = false;
  bool _correct = false;
  String _course = MockData.courseNames.first;

  int get _qIdx => _current % MockData.quizQuestions.length;

  @override
  Widget build(BuildContext context) {
    final q = MockData.quizQuestions[_qIdx];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.isTablet ? 28 : 20),
          child: Column(
            children: [
              Row(
                children: [
                  const BackIfPushed(),
                  CourseDropdown(
                    selected: _course,
                    options: MockData.courseNames,
                    onChanged: (v) => setState(() => _course = v),
                  ),
                  const Spacer(),
                  Text(
                    '${_current + 1} / $_total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink60,
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
                q.question,
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
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 170,
                child: MulgilCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _correct ? '정답!' : '오답',
                        style: TextStyle(
                          color: _correct
                              ? AppColors.tealDark
                              : AppColors.coral,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        q.explanation,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink80,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                    '프로세스 스케줄링',
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
                  _TabletHint(),
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
                        q.question,
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
                        q.explanation,
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
            child: _ChoiceButton(
              index: i,
              label: options[i],
              selected: _showResult && i == q.answer,
              wrong: _showResult && !_correct && i != q.answer,
              onTap: _showResult ? null : () => _answer(i, q),
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _OxButton(
            label: 'O',
            color: AppColors.tealDark,
            onTap: () => _answer(0, q),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _OxButton(
            label: 'X',
            color: AppColors.coral,
            onTap: () => _answer(1, q),
          ),
        ),
      ],
    );
  }

  void _answer(int choice, QuizQuestion q) {
    setState(() {
      _correct = choice == q.answer;
      _showResult = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _current = (_current + 1) % _total;
        _showResult = false;
      });
    });
  }
}

class _TabletHint extends StatelessWidget {
  const _TabletHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Text(
        '⭐ 긴 작업이 계속 밀려 실행되지 못하는 기아 현상(starvation)이 발생할 수 있다.',
        style: TextStyle(fontSize: 12.5, color: AppColors.ink80, height: 1.7),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final int index;
  final String label;
  final bool selected;
  final bool wrong;
  final VoidCallback? onTap;
  const _ChoiceButton({
    required this.index,
    required this.label,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.tealDark
        : (wrong ? AppColors.coralSoft : AppColors.surface);
    final border = selected
        ? AppColors.tealDark
        : (wrong ? AppColors.coral : AppColors.border);
    final fg = selected ? Colors.white : AppColors.ink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.chip,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _letters[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OxButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OxButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
