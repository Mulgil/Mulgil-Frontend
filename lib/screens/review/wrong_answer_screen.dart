import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/wrong_answer.dart';
import '../../constants/routes.dart';
import 'widgets/wrong_answer_card.dart';
import 'widgets/wrong_answer_empty_box.dart';
import 'widgets/wrong_answer_stats_card.dart';

const _kAll = '전체';

class WrongAnswerScreen extends StatefulWidget {
  const WrongAnswerScreen({super.key});

  @override
  State<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends State<WrongAnswerScreen> {
  String _courseFilter = _kAll;

  List<String> get _filters => [_kAll, ...MockData.courseNames];

  List<WrongAnswer> get _filteredAnswers => _courseFilter == _kAll
      ? MockData.wrongAnswers
      : MockData.wrongAnswers
            .where((w) => w.courseName == _courseFilter)
            .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: context.isTablet ? _buildTablet() : _buildMobile()),
    );
  }

  Widget _buildMobile() {
    final answers = _filteredAnswers;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              BackIfPushed(),
              Text(
                '오답 노트',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FilterBar(
            filters: _filters,
            selected: _courseFilter,
            onSelect: (s) => setState(() => _courseFilter = s),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: answers.isEmpty
                ? const WrongAnswerEmptyBox()
                : ListView.separated(
                    itemCount: answers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => WrongAnswerCard(item: answers[i]),
                  ),
          ),
          const SizedBox(height: 16),
          MulgilButton(
            label: '오답만 다시 퀴즈',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTablet() {
    final answers = _filteredAnswers;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: MaxContentWidth(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오답 노트', style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  _FilterBar(
                    filters: _filters,
                    selected: _courseFilter,
                    onSelect: (s) => setState(() => _courseFilter = s),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: answers.isEmpty
                        ? const WrongAnswerEmptyBox()
                        : ListView.separated(
                            itemCount: answers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) =>
                                WrongAnswerCard(item: answers[i]),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),
            SizedBox(
              width: 280,
              child: Column(
                children: [
                  const WrongAnswerStatsCard(),
                  const SizedBox(height: 16),
                  MulgilButton(
                    label: '오답만 다시 퀴즈',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.quiz),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterBar({
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: MulgilChip(
                  label: s,
                  selected: selected == s,
                  onTap: () => onSelect(s),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
