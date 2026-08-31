import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/wrong_answer.dart';

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
          Row(
            children: [
              const BackIfPushed(),
              const Text(
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MulgilChip(
                        label: s,
                        selected: _courseFilter == s,
                        onTap: () => setState(() => _courseFilter = s),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: answers.isEmpty
                ? const _EmptyBox()
                : ListView.separated(
                    itemCount: answers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _WrongCard(item: answers[i]),
                  ),
          ),
          const SizedBox(height: 16),
          MulgilButton(
            label: '오답만 다시 퀴즈',
            onTap: () => Navigator.of(context).pushNamed('/quiz'),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오답 노트', style: AppTextStyles.h2),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: MulgilChip(
                              label: s,
                              selected: _courseFilter == s,
                              onTap: () => setState(() => _courseFilter = s),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: answers.isEmpty
                      ? const _EmptyBox()
                      : ListView.separated(
                          itemCount: answers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _WrongCard(item: answers[i]),
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
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이번 학기 오답',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9fb6c4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${MockData.wrongAnswers.length}개',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MulgilButton(
                  label: '오답만 다시 퀴즈',
                  onTap: () => Navigator.of(context).pushNamed('/quiz'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MulgilCard(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: const Center(
          child: Text(
            '해당하는 오답이 없어요',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}

class _WrongCard extends StatelessWidget {
  final WrongAnswer item;
  const _WrongCard({required this.item});

  void _retry(BuildContext context) => Navigator.of(context).pushNamed('/quiz');

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.courseName,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.question,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '내 답: ${item.myAnswer}',
                style: const TextStyle(fontSize: 12, color: AppColors.coral),
              ),
              const SizedBox(width: 10),
              Text(
                '정답: ${item.correct}',
                style: const TextStyle(fontSize: 12, color: AppColors.tealDark),
              ),
            ],
          ),
          if (item.isProfEmphasis) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.coralSoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text(
                '교수님 강조 개념',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _retry(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.navy),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: const Text(
                '다시 풀기',
                style: TextStyle(fontSize: 12, color: AppColors.navy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
