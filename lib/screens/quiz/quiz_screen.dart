import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/quiz_question.dart';
import '../../models/wrong_answer.dart';
import '../review/widgets/wrong_answer_card.dart';
import '../review/widgets/wrong_answer_empty_box.dart';
import '../review/widgets/wrong_answer_stats_card.dart';
import 'widgets/quiz_answer_buttons.dart';
import 'widgets/quiz_result_card.dart';
import 'widgets/quiz_tablet_hint.dart';

class QuizScreen extends StatefulWidget {
  final String? initialCourse;
  const QuizScreen({super.key, this.initialCourse});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late String _course = widget.initialCourse ?? MockData.courseNames.first;

  int _current = 3;
  static const int _total = 10;
  bool _showResult = false;
  bool _correct = false;

  int get _qIdx => _current % MockData.quizQuestions.length;

  List<WrongAnswer> get _courseWrongAnswers =>
      MockData.wrongAnswers.where((w) => w.courseName == _course).toList();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  CourseDropdown(
                    selected: _course,
                    options: MockData.courseNames,
                    onChanged: (v) => setState(() => _course = v),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTabBar(),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _buildQuizTab(context),
                    _buildWrongAnswerTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.ink60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '퀴즈'),
          Tab(text: '오답노트'),
        ],
      ),
    );
  }

  Widget _buildQuizTab(BuildContext context) {
    final q = MockData.quizQuestions[_qIdx];
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Text(
              '${_current + 1} / $_total',
              style: const TextStyle(fontSize: 12, color: AppColors.ink60),
            ),
          ],
        ),
        const SizedBox(height: 10),
        MulgilProgressBar(value: (_current + 1) / _total),
        const SizedBox(height: 24),
        if (context.isTablet) _buildTabletQuiz(q) else _buildMobileQuiz(q),
      ],
    );
  }

  Widget _buildWrongAnswerTab(BuildContext context) {
    final answers = _courseWrongAnswers;
    final list = answers.isEmpty
        ? const WrongAnswerEmptyBox()
        : ListView.separated(
            itemCount: answers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => WrongAnswerCard(item: answers[i]),
          );

    if (context.isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: list),
          const SizedBox(width: 28),
          SizedBox(
            width: 280,
            child: Column(
              children: [
                const WrongAnswerStatsCard(),
                const SizedBox(height: 16),
                MulgilButton(
                  label: '오답만 다시 퀴즈',
                  onTap: () => _tab.animateTo(0),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(child: list),
        const SizedBox(height: 16),
        MulgilButton(label: '오답만 다시 퀴즈', onTap: () => _tab.animateTo(0)),
        const SizedBox(height: 8),
      ],
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
            QuizResultCard(correct: _correct, explanation: q.explanation),
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
            child: ChoiceButton(
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
