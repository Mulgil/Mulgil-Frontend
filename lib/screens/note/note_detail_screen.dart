import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import '../../models/draw_stroke.dart';
import '../../utils/stroke_eraser.dart';
import 'widgets/note_canvas.dart';
import 'widgets/note_drawing_footer.dart';
import 'widgets/note_header.dart';
import 'widgets/note_mode_toggle.dart';
import 'widgets/note_page_sidebar.dart';
import 'widgets/note_review.dart';
import 'widgets/note_toolbar.dart';
import 'widgets/note_typed_widgets.dart';

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
  final _typedCtrl = TextEditingController();
  bool _contentLoaded = false;
  late Lecture _lecture;
  static const _pageCount = 4;
  int _currentPage = 0;
  bool _pageSidebarVisible = true;
  final Map<int, List<DrawStroke>> _pageStrokes = {};
  final Map<int, List<_DrawAction>> _pageHistory = {};
  final Map<int, List<_DrawAction>> _pageRedo = {};
  List<DrawStroke> _eraseBeforeSnapshot = [];
  bool _eraseChanged = false;
  DrawStroke? _currentStroke;

  List<DrawStroke> get _strokes => _pageStrokes.putIfAbsent(
    _currentPage,
    () => List.of(NotesStore.instance.pageStrokes(_lecture, _currentPage)),
  );
  List<_DrawAction> get _history =>
      _pageHistory.putIfAbsent(_currentPage, () => []);
  List<_DrawAction> get _redoHistory =>
      _pageRedo.putIfAbsent(_currentPage, () => []);
  // Mirrors PATCH /notes/{id} — saved on debounce, matching the drawing mode's "저장됨" indicator.
  bool _typedSaving = false;
  Timer? _saveTimer;

  DrawTool get _currentTool => switch (_tool) {
    1 => DrawTool.highlighter,
    2 => DrawTool.eraser,
    3 => DrawTool.strokeEraser,
    _ => DrawTool.pen,
  };

  void _onTypedChanged() {
    NotesStore.instance.updateTypedText(_lecture, _typedCtrl.text);
    setState(() => _typedSaving = true);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _typedSaving = false);
    });
  }

  final List<PendingHandwritingBlock> _pendingReview = [
    PendingHandwritingBlock(id: 'hb1', guess: MockData.pendingHandwritingGuess),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_contentLoaded) {
      _contentLoaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      _lecture = args is Lecture ? args : MockData.lectures.first;
      _typedCtrl.text = NotesStore.instance.contentFor(_lecture).typedText;
      _typedCtrl.addListener(_onTypedChanged);
    }
  }

  @override
  void dispose() {
    _typedCtrl.removeListener(_onTypedChanged);
    _typedCtrl.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  void _startStroke(Offset pos) {
    if (_currentTool == DrawTool.eraser ||
        _currentTool == DrawTool.strokeEraser) {
      _eraseBeforeSnapshot = List.of(_strokes);
      _eraseChanged = false;
      if (_currentTool == DrawTool.eraser) {
        _eraseAt(pos);
      } else {
        _eraseStrokeAt(pos);
      }
      return;
    }
    setState(() {
      _currentStroke = DrawStroke(
        tool: _currentTool,
        color: _currentTool == DrawTool.highlighter
            ? AppColors.yellow.withValues(alpha: 0.45)
            : AppColors.navy,
        width: _currentTool == DrawTool.highlighter ? 16 : 2.5,
        points: [pos],
      );
    });
  }

  void _extendStroke(Offset pos) {
    if (_currentTool == DrawTool.eraser) {
      _eraseAt(pos);
      return;
    }
    if (_currentTool == DrawTool.strokeEraser) {
      _eraseStrokeAt(pos);
      return;
    }
    if (_currentStroke == null) return;
    setState(() => _currentStroke!.points.add(pos));
  }

  void _endStroke() {
    if (_currentTool == DrawTool.eraser ||
        _currentTool == DrawTool.strokeEraser) {
      if (_eraseChanged) {
        _history.add(_DrawAction(_eraseBeforeSnapshot, List.of(_strokes)));
        _redoHistory.clear();
        _eraseChanged = false;
        _persistCurrentPage();
      }
      return;
    }
    if (_currentStroke == null) return;
    final before = List.of(_strokes);
    final stroke = _currentStroke!;
    setState(() {
      _strokes.add(stroke);
      _currentStroke = null;
    });
    _history.add(_DrawAction(before, List.of(_strokes)));
    _redoHistory.clear();
    _persistCurrentPage();
  }

  void _eraseStrokeAt(Offset pos) {
    const hitRadius = 14.0;
    final touched = StrokeEraser.strokesNear(_strokes, pos, hitRadius);
    if (touched.isEmpty) return;
    setState(() {
      for (final s in touched) {
        _strokes.remove(s);
      }
      _eraseChanged = true;
    });
  }

  void _eraseAt(Offset pos) {
    const hitRadius = 14.0;
    final touched = StrokeEraser.strokesNear(_strokes, pos, hitRadius);
    if (touched.isEmpty) return;
    setState(() {
      for (final s in touched) {
        _strokes.remove(s);
        _strokes.addAll(StrokeEraser.erasePortion(s, pos, hitRadius));
      }
      _eraseChanged = true;
    });
  }

  void _persistCurrentPage() =>
      NotesStore.instance.updatePageStrokes(_lecture, _currentPage, _strokes);

  bool get _canUndo => _history.isNotEmpty;
  bool get _canRedo => _redoHistory.isNotEmpty;

  void _undo() {
    if (_history.isEmpty) return;
    final action = _history.removeLast();
    setState(() {
      _strokes
        ..clear()
        ..addAll(action.before);
    });
    _redoHistory.add(action);
    _persistCurrentPage();
  }

  void _redo() {
    if (_redoHistory.isEmpty) return;
    final action = _redoHistory.removeLast();
    setState(() {
      _strokes
        ..clear()
        ..addAll(action.after);
    });
    _history.add(action);
    _persistCurrentPage();
  }

  void _openMenuSheet() {
    showNoteDetailMenuSheet(
      context,
      hasPendingReview: _pendingReview.isNotEmpty,
      onOpenReview: _openReviewSheet,
    );
  }

  void _openReviewSheet() {
    showNoteReviewSheet(
      context,
      pendingReview: _pendingReview,
      onBlockConfirmed: (block) => setState(() => _pendingReview.remove(block)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDrawing = _mode == _NoteMode.drawing;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          NoteDetailHeader(
            title: '${_lecture.week} · ${_lecture.title}',
            onBack: () => Navigator.pop(context),
            onMenu: _openMenuSheet,
          ),
          NoteModeToggle(
            isDrawing: isDrawing,
            onSelectDrawing: () => setState(() => _mode = _NoteMode.drawing),
            onSelectTyped: () => setState(() => _mode = _NoteMode.typed),
          ),
          if (isDrawing) ...[
            NoteToolbar(
              selectedTool: _tool,
              onToolSelected: (i) => setState(() => _tool = i),
              canUndo: _canUndo,
              canRedo: _canRedo,
              onUndo: _undo,
              onRedo: _redo,
              showProfTag: _showProfTag,
              onToggleProfTag: () =>
                  setState(() => _showProfTag = !_showProfTag),
            ),
            if (_pendingReview.isNotEmpty)
              NoteReviewBanner(
                count: _pendingReview.length,
                onTap: _openReviewSheet,
              ),
          ],
          Expanded(
            child: isDrawing
                ? (context.isTablet
                      ? _buildTabletLayout()
                      : _buildCanvas())
                : NoteTypedEditor(controller: _typedCtrl),
          ),
          if (isDrawing)
            NoteDrawingFooter(
              currentPage: _currentPage,
              pageCount: _pageCount,
              onPrevPage: _currentPage > 0
                  ? () => setState(() => _currentPage--)
                  : null,
              onNextPage: _currentPage < _pageCount - 1
                  ? () => setState(() => _currentPage++)
                  : null,
            )
          else
            NoteTypedFooter(
              wordCount: _typedCtrl.text.trim().isEmpty
                  ? 0
                  : _typedCtrl.text.trim().split(RegExp(r'\s+')).length,
              saving: _typedSaving,
            ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return NoteCanvas(
      showProfTag: _showProfTag,
      strokes: _strokes,
      currentStroke: _currentStroke,
      onPanStart: (d) => _startStroke(d.localPosition),
      onPanUpdate: (d) => _extendStroke(d.localPosition),
      onPanEnd: (_) => _endStroke(),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        NotePageSidebar(
          pageCount: _pageCount,
          currentPage: _currentPage,
          visible: _pageSidebarVisible,
          onPageSelected: (i) => setState(() => _currentPage = i),
          onCollapse: () => setState(() => _pageSidebarVisible = false),
          onExpand: () => setState(() => _pageSidebarVisible = true),
        ),
        Expanded(child: _buildCanvas()),
      ],
    );
  }
}

class _DrawAction {
  final List<DrawStroke> before;
  final List<DrawStroke> after;
  _DrawAction(this.before, this.after);
}
