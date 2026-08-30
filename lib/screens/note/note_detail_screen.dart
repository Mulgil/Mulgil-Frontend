import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

enum _NoteMode { drawing, typed }

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  _NoteMode _mode = _NoteMode.drawing;
  int _tool = 0;
  bool _showProfTag = true;
  final _typedCtrl = TextEditingController(text: '# 2주차 - 프로세스\n\n');
  // Mirrors PATCH /notes/{id} — saved on debounce, matching the drawing mode's "저장됨" indicator.
  bool _typedSaving = false;
  Timer? _saveTimer;

  void _onTypedChanged() {
    setState(() => _typedSaving = true);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _typedSaving = false);
    });
  }
  // Mirrors PATCH /handwriting-blocks/{id}/confirm — OCR confidence < 0.80 needs user confirm before AI can use it.
  final List<_PendingHandwritingBlock> _pendingReview = [
    _PendingHandwritingBlock(id: 'hb1', guess: '세마포어는 P/V 연산으로 제어된다'),
  ];

  static const _tools = [
    {'icon': '✎', 'label': '펜', 'color': AppColors.navy},
    {'icon': '▮', 'label': '형광펜', 'color': Colors.transparent},
    {'icon': '⌫', 'label': '지우개', 'color': Colors.transparent},
  ];

  @override
  void initState() {
    super.initState();
    _typedCtrl.addListener(_onTypedChanged);
  }

  @override
  void dispose() {
    _typedCtrl.removeListener(_onTypedChanged);
    _typedCtrl.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDrawing = _mode == _NoteMode.drawing;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          _buildModeToggle(),
          if (isDrawing) ...[
            _buildToolbar(),
            if (_pendingReview.isNotEmpty) _buildReviewBanner(),
          ],
          Expanded(
            child: isDrawing
                ? (context.isTablet ? _buildTabletLayout() : _buildMobileCanvas())
                : _buildTypedEditor(),
          ),
          if (isDrawing) _buildFooter() else _buildTypedFooter(),
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
            GestureDetector(onTap: () => _openMenuSheet(context), child: const Text('☰', style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  void _openMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.navy),
              title: const Text('원본 PDF 보기'),
              onTap: () {
                Navigator.pop(sheetCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다운로드 URL 요청 중... (mock)')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined, color: AppColors.navy),
              title: const Text('AI 요약으로 이동'),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).pushNamed('/summary');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_outlined, color: AppColors.navy),
              title: const Text('손글씨 확인 항목 다시 열기'),
              onTap: () {
                Navigator.pop(sheetCtx);
                if (_pendingReview.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('확인이 필요한 손글씨가 없어요')),
                  );
                } else {
                  _openReviewSheet();
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          Expanded(child: _ModeTab(label: '✎ 필기', selected: _mode == _NoteMode.drawing, onTap: () => setState(() => _mode = _NoteMode.drawing))),
          const SizedBox(width: 8),
          Expanded(child: _ModeTab(label: '⌨ 타이핑 노트', selected: _mode == _NoteMode.typed, onTap: () => setState(() => _mode = _NoteMode.typed))),
        ],
      ),
    );
  }

  Widget _buildTypedEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _typedCtrl,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '마크다운으로 정리해보세요...',
        ),
      ),
    );
  }

  Widget _buildTypedFooter() {
    final wordCount = _typedCtrl.text.trim().isEmpty ? 0 : _typedCtrl.text.trim().split(RegExp(r'\s+')).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$wordCount 단어', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          Text(
            _typedSaving ? '저장 중...' : '● 저장됨',
            style: TextStyle(fontSize: 11, color: _typedSaving ? AppColors.textLight : AppColors.teal),
          ),
        ],
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

  Widget _buildReviewBanner() {
    return GestureDetector(
      onTap: _openReviewSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFFFFF3E9),
        child: Row(
          children: [
            const Icon(Icons.edit_note, size: 16, color: Color(0xFFB15400)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '손글씨 확인이 필요해요 (${_pendingReview.length}건) · 확인 전까지 AI 생성에 반영되지 않아요',
                style: const TextStyle(fontSize: 12, color: Color(0xFFB15400)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFFB15400)),
          ],
        ),
      ),
    );
  }

  void _openReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, sheetSetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('손글씨 인식 확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('AI가 읽은 내용이 맞는지 확인하고 필요하면 수정해주세요', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                ..._pendingReview.map((b) => _ReviewBlockField(
                  block: b,
                  onConfirm: (text) {
                    setState(() => _pendingReview.remove(b));
                    sheetSetState(() {});
                    if (_pendingReview.isEmpty) Navigator.pop(sheetCtx);
                  },
                )),
              ],
            ),
          );
        },
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 110, height: 20,
                  decoration: BoxDecoration(border: Border.all(color: AppColors.coral, width: 2, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                ),
                Positioned(
                  top: -10, left: 90,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(6)),
                    child: const Text('⭐⭐', style: TextStyle(fontSize: 9, color: Colors.white)),
                  ),
                ),
              ],
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

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textPrimary)),
          ),
        ),
      ),
    );
  }
}

class _PendingHandwritingBlock {
  final String id;
  final String guess;
  _PendingHandwritingBlock({required this.id, required this.guess});
}

class _ReviewBlockField extends StatefulWidget {
  final _PendingHandwritingBlock block;
  final ValueChanged<String> onConfirm;
  const _ReviewBlockField({required this.block, required this.onConfirm});

  @override
  State<_ReviewBlockField> createState() => _ReviewBlockFieldState();
}

class _ReviewBlockFieldState extends State<_ReviewBlockField> {
  late final _ctrl = TextEditingController(text: widget.block.guess);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'AI 인식 결과 (신뢰도 낮음)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          MulgilButton(label: '확인', onTap: () => widget.onConfirm(_ctrl.text)),
        ],
      ),
    );
  }
}
