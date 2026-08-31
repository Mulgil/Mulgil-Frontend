import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/summary_item.dart';
import '../../constants/routes.dart';

class AiSummaryScreen extends StatefulWidget {
  const AiSummaryScreen({super.key});

  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _course = MockData.courseNames.first;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _SummaryTab(isTablet: context.isTablet),
                  const _MindmapTab(),
                  const _OriginalTab(),
                ],
              ),
            ),
            if (!context.isTablet)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: MulgilButton(
                  label: '퀴즈 풀기',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'AI 요약 · ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          CourseDropdown(
            selected: _course,
            options: MockData.courseNames,
            onChanged: (v) => setState(() => _course = v),
            fontSize: 15,
          ),
          const Expanded(
            child: Text(
              ' 2주차',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Text(
              '✨ AI 생성',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.tealDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
          Tab(text: '요약'),
          Tab(text: '마인드맵'),
          Tab(text: '원본 필기'),
        ],
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final bool isTablet;
  const _SummaryTab({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      child: isTablet ? _buildTabletLayout(context) : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ...MockData.summaryItems.map((item) => _SummaryItemCard(item: item)),
        const SizedBox(height: 12),
        const _ProfEmphasisBlock(),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: MockData.summaryItems
                .map((item) => _SummaryItemCard(item: item))
                .toList(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const _ProfEmphasisBlock(),
              const SizedBox(height: 16),
              MulgilButton(
                label: '퀴즈 풀기',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryItemCard extends StatelessWidget {
  final SummaryItem item;
  const _SummaryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: item.isEmphasis
              ? AppColors.coral.withValues(alpha: 0.4)
              : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              if (item.isEmphasis) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.coralSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    '⭐ 교수님 강조',
                    style: TextStyle(fontSize: 10, color: AppColors.coral),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.ink80,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfEmphasisBlock extends StatelessWidget {
  const _ProfEmphasisBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 교수님 강조 포인트',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            MockData.profEmphasisPoint.title,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            MockData.profEmphasisPoint.body,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink80,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _MindmapTab extends StatelessWidget {
  const _MindmapTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          height: 340,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: CustomPaint(
            painter: _MindmapPainter(
              centerLabel: MockData.mindmapCenterLabel,
              nodeLabels: MockData.mindmapNodeLabels,
            ),
            child: const Center(),
          ),
        ),
      ),
    );
  }
}

// Fixed 4-node radial layout — the offsets are a visual template, not data,
// so `nodeLabels` must have exactly 4 entries to match.
class _MindmapPainter extends CustomPainter {
  final String centerLabel;
  final List<String> nodeLabels;
  _MindmapPainter({required this.centerLabel, required this.nodeLabels})
    : assert(nodeLabels.length == 4);

  static const _offsets = [
    Offset(-120, -80),
    Offset(120, -80),
    Offset(-120, 80),
    Offset(120, 80),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final linePaint = Paint()
      ..color = const Color(0xFFB0C8D4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final centerPaint = Paint()..color = AppColors.navy;
    final nodePaint = Paint()..color = AppColors.teal.withValues(alpha: 0.8);

    canvas.drawCircle(Offset(cx, cy), 42, centerPaint);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: centerLabel,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    // Bounds the loop to whichever list is shorter so a `nodeLabels` list
    // that drifts from 4 entries can't index past either array — the assert
    // below is a debug-time early warning, not the actual safety net (Dart
    // strips asserts from release builds).
    final nodeCount = math.min(_offsets.length, nodeLabels.length);
    for (var i = 0; i < nodeCount; i++) {
      final dx = _offsets[i].dx;
      final dy = _offsets[i].dy;
      canvas.drawLine(Offset(cx, cy), Offset(cx + dx, cy + dy), linePaint);
      canvas.drawCircle(Offset(cx + dx, cy + dy), 28, nodePaint);
      final lbl = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: nodeLabels[i],
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
      lbl.layout();
      lbl.paint(
        canvas,
        Offset(cx + dx - lbl.width / 2, cy + dy - lbl.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _OriginalTab extends StatelessWidget {
  const _OriginalTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, p) in MockData.originalNoteParagraphs.indexed) ...[
            Text(
              p,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.ink80,
                height: 1.7,
              ),
            ),
            if (i != MockData.originalNoteParagraphs.length - 1)
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
