import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/summary_item.dart';

class AiSummaryScreen extends StatefulWidget {
  const AiSummaryScreen({super.key});

  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

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
            Expanded(child: TabBarView(controller: _tab, children: [_SummaryTab(isTablet: context.isTablet), const _MindmapTab(), const _OriginalTab()])),
            if (!context.isTablet) Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: MulgilButton(label: '퀴즈 만들기', onTap: () => Navigator.of(context).pushNamed('/quiz')),
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
          GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          const Expanded(child: Text('AI 요약 · 운영체제 2주차', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEEF7F8), borderRadius: BorderRadius.circular(10)),
            child: const Text('✨ AI 생성', style: TextStyle(fontSize: 11, color: AppColors.tealDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(color: const Color(0xFFF2F3F5), borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: '요약'), Tab(text: '마인드맵'), Tab(text: '원본 필기')],
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
      child: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
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

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: MockData.summaryItems.map((item) => _SummaryItemCard(item: item)).toList(),
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          flex: 2,
          child: Column(
            children: [
              _ProfEmphasisBlock(),
              SizedBox(height: 16),
              MulgilButton(label: '퀴즈 만들기'),
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
        color: Colors.white,
        border: Border.all(color: item.isEmphasis ? AppColors.coral.withValues(alpha: 0.4) : const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              if (item.isEmphasis) ...[
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFF0EB), borderRadius: BorderRadius.circular(6)), child: const Text('⭐ 교수님 강조', style: TextStyle(fontSize: 10, color: AppColors.coral))),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(item.body, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.6)),
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
      decoration: BoxDecoration(color: const Color(0xFFFFF8F5), border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(14)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎯 교수님 강조 포인트', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.coral)),
          SizedBox(height: 8),
          Text('세마포어의 P(wait) / V(signal) 연산', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('세마포어는 공유 자원 접근을 제어하는 정수형 변수로, 이진/계수 세마포어로 나뉜다.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
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
          decoration: BoxDecoration(color: const Color(0xFFF8FAFB), border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(16)),
          child: CustomPaint(painter: _MindmapPainter(), child: const Center()),
        ),
      ),
    );
  }
}

class _MindmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final linePaint = Paint()..color = const Color(0xFFB0C8D4)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final centerPaint = Paint()..color = AppColors.navy;
    final nodePaint = Paint()..color = AppColors.teal.withValues(alpha: 0.8);

    canvas.drawCircle(Offset(cx, cy), 42, centerPaint);

    const nodes = [
      {'dx': -120.0, 'dy': -80.0, 'label': '프로세스'},
      {'dx': 120.0, 'dy': -80.0, 'label': '스레드'},
      {'dx': -120.0, 'dy': 80.0, 'label': '스케줄링'},
      {'dx': 120.0, 'dy': 80.0, 'label': '동기화'},
    ];

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = const TextSpan(text: '운영체제', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700));
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    for (final n in nodes) {
      final dx = n['dx'] as double;
      final dy = n['dy'] as double;
      canvas.drawLine(Offset(cx, cy), Offset(cx + dx, cy + dy), linePaint);
      canvas.drawCircle(Offset(cx + dx, cy + dy), 28, nodePaint);
      final lbl = TextPainter(textDirection: TextDirection.ltr, text: TextSpan(text: n['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 10)));
      lbl.layout();
      lbl.paint(canvas, Offset(cx + dx - lbl.width / 2, cy + dy - lbl.height / 2));
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
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(14)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('텍스트입니다 텍스트입니다', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.7)),
          SizedBox(height: 8),
          Text('텍스트입니다 텍스트입니다 텍스트입니다', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.7)),
          SizedBox(height: 8),
          Text('텍스트입니다', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.7)),
        ],
      ),
    );
  }
}
