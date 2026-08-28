import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  int _tool = 0;
  bool _showProfTag = true;

  static const _tools = [
    {'icon': '✎', 'label': '펜', 'color': AppColors.navy},
    {'icon': '▮', 'label': '형광펜', 'color': Colors.transparent},
    {'icon': '⌫', 'label': '지우개', 'color': Colors.transparent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          _buildToolbar(),
          Expanded(
            child: context.isTablet ? _buildTabletLayout() : _buildMobileCanvas(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
        child: Row(
          children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: const Text('←', style: TextStyle(fontSize: 18))),
            const Spacer(),
            Column(
              children: const [
                Text('운영체제 · 2주차', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('● 저장됨', style: TextStyle(fontSize: 10, color: AppColors.teal)),
              ],
            ),
            const Spacer(),
            const Text('☰', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ..._tools.asMap().entries.map((e) {
              final sel = _tool == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _tool = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.navy : const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${e.value['icon']} ${e.value['label']}',
                      style: TextStyle(fontSize: 13, color: sel ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                ),
              );
            }),
            Container(width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 4), color: const Color(0xFFDDDDDD)),
            GestureDetector(
              onTap: () => setState(() => _showProfTag = !_showProfTag),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _showProfTag ? AppColors.coral : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('교수★', style: TextStyle(fontSize: 13, color: _showProfTag ? Colors.white : AppColors.textPrimary)),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
              child: const Text('가 텍스트', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCanvas() {
    return Stack(
      children: [
        Container(color: const Color(0xFFFAFAFA), padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('텍스트입니다 텍스트입니다', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              const Text('텍스트입니다', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                height: 70, width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0F2),
                  border: Border.all(color: const Color(0xFFC8CCD0), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text('이미지 / 다이어그램', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              ),
              const SizedBox(height: 16),
              const Text('텍스트입니다 텍스트입니다', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(height: 16, color: const Color(0x80F5C842)),
                  const Text('텍스트입니다', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        if (_showProfTag)
          Positioned(
            left: 40, top: 160,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(border: Border.all(color: AppColors.coral, width: 2, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: -10, left: 90),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(6)),
                    child: const Text('⭐⭐', style: TextStyle(fontSize: 9, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          left: 24, bottom: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))]),
            child: const Text('언급 빈도 +1 · ⭐⭐', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Page thumbnails sidebar
        Container(
          width: 100,
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFEEEEEE)))),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: 4,
            itemBuilder: (_, i) => Container(
              height: 70,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: i == 0 ? const Color(0xFFEEF7F8) : const Color(0xFFF7F7F7),
                border: i == 0 ? Border.all(color: AppColors.teal, width: 1.5) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('${i + 1} 페이지', style: TextStyle(fontSize: 11, color: i == 0 ? AppColors.tealDark : AppColors.textLight)),
            ),
          ),
        ),
        // Canvas
        Expanded(child: _buildMobileCanvas()),
        // Right toolbar
        Container(
          width: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              ...[
                {'icon': '✎', 'bg': AppColors.navy, 'fg': Colors.white},
                {'icon': '▮', 'bg': Colors.transparent, 'fg': AppColors.textMuted},
                {'icon': '⌫', 'bg': Colors.transparent, 'fg': AppColors.textMuted},
                {'icon': '⬚', 'bg': Colors.transparent, 'fg': AppColors.textMuted},
              ].map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: t['bg'] as Color, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(t['icon'] as String, style: TextStyle(fontSize: 15, color: t['fg'] as Color)),
                ),
              )),
              Container(width: 24, height: 1, color: const Color(0xFFEEEEEE), margin: const EdgeInsets.symmetric(vertical: 4)),
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text('★', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('1 / 12 페이지', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
          Text('확대 100%', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
