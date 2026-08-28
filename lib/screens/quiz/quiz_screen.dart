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

  int get _qIdx => _current % MockData.quizQuestions.length;

  @override
  Widget build(BuildContext context) {
    final q = MockData.quizQuestions[_qIdx];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.isTablet ? 40 : 24),
          child: Column(
            children: [
              MulgilProgressBar(value: (_current + 1) / _total),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: Text('${_current + 1} / $_total', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
              const SizedBox(height: 24),
              if (context.isTablet) _buildTabletQuiz(q) else _buildMobileQuiz(q),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Text(q.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _OxButton(label: 'O', color: AppColors.tealDark, onTap: () => _answer(0, q))),
              const SizedBox(width: 14),
              Expanded(child: _OxButton(label: 'X', color: AppColors.coral, onTap: () => _answer(1, q))),
            ],
          ),
          const SizedBox(height: 16),
          Text('남은 문제 ${_total - _current - 1}개 · 예상 시간 ${(_total - _current - 1) * 30}초', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const Spacer(),
          if (_showResult)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 170,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 6))],
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_correct ? '정답!' : '오답', style: TextStyle(color: _correct ? AppColors.tealDark : AppColors.coral, fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(q.explanation, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5)),
                  ],
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
              decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('참고 자료', style: TextStyle(fontSize: 11.5, color: AppColors.textLight)),
                  SizedBox(height: 10),
                  Text('프로세스 스케줄링', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 6),
                  Text(
                    'SJF(Shortest Job First)는 실행 시간이 짧은 작업을 우선 처리하는 스케줄링 기법이다.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.7),
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
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Text(q.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: _OxButton(label: 'O', color: AppColors.tealDark, onTap: () => _answer(0, q))),
                      const SizedBox(width: 14),
                      Expanded(child: _OxButton(label: 'X', color: AppColors.coral, onTap: () => _answer(1, q))),
                    ],
                  ),
                  if (_showResult) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.yellow),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(q.explanation, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
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
      decoration: BoxDecoration(color: const Color(0xFFFFF9DB), borderRadius: BorderRadius.circular(8)),
      child: const Text(
        '⭐ 긴 작업이 계속 밀려 실행되지 못하는 기아 현상(starvation)이 발생할 수 있다.',
        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.7),
      ),
    );
  }
}

class _OxButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OxButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}
