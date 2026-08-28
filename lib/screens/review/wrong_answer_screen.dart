import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/wrong_answer.dart';

class WrongAnswerScreen extends StatefulWidget {
  const WrongAnswerScreen({super.key});

  @override
  State<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends State<WrongAnswerScreen> {
  int _filter = 0;
  static const _filters = ['전체', '이번 퀴즈', '많이 틀린 순'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: context.isTablet ? _buildTablet() : _buildMobile(),
      ),
    );
  }

  Widget _buildMobile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오답 노트 · 운영체제', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _filters.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(right: 8), child: MulgilChip(label: e.value, selected: _filter == e.key, onTap: () => setState(() => _filter = e.key)))).toList()),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: MockData.wrongAnswers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _WrongCard(item: MockData.wrongAnswers[i]),
            ),
          ),
          const SizedBox(height: 16),
          MulgilButton(label: '오답만 다시 퀴즈'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTablet() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('오답 노트', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: ['전체', '운영체제', '자료구조', '많이 틀린 순'].map((s) => Padding(padding: const EdgeInsets.only(right: 8), child: MulgilChip(label: s, selected: s == '전체'))).toList()),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: MockData.wrongAnswers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _WrongCard(item: MockData.wrongAnswers[i]),
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
                  decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이번 학기 오답', style: TextStyle(fontSize: 13, color: Color(0xFF9fb6c4))),
                      SizedBox(height: 4),
                      Text('23개', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MulgilButton(label: '오답만 다시 퀴즈'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WrongCard extends StatelessWidget {
  final WrongAnswer item;
  const _WrongCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.question, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('내 답: ${item.myAnswer}', style: const TextStyle(fontSize: 12, color: AppColors.coral)),
              const SizedBox(width: 10),
              Text('정답: ${item.correct}', style: const TextStyle(fontSize: 12, color: AppColors.tealDark)),
            ],
          ),
          if (item.isProfEmphasis) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFFF3E9), borderRadius: BorderRadius.circular(8)),
              child: const Text('교수님 강조 개념', style: TextStyle(fontSize: 10.5, color: Color(0xFFB15400))),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: AppColors.navy), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: const Text('다시 풀기', style: TextStyle(fontSize: 12, color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}
