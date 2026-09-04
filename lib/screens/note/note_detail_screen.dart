import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../data/learning_domain_store.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import '../../models/draw_stroke.dart';
import '../../models/prof_mention.dart';
import '../../utils/stroke_eraser.dart';
import 'widgets/note_canvas.dart';
import 'widgets/note_drawing_footer.dart';
import 'widgets/note_header.dart';
import 'widgets/note_mode_toggle.dart';
import 'widgets/note_page_sidebar.dart';
import 'widgets/note_review.dart';
import 'widgets/note_toolbar.dart';
import 'widgets/note_typed_widgets.dart';
import 'widgets/session_materials_sheet.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

enum _NoteMode { drawing, typed }

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  _NoteMode _mode = _NoteMode.drawing;
  int _tool = 0;
  static const _mentionTool = 4;
  final _typedCtrl = TextEditingController();
  bool _contentLoaded = false;
  Lecture? _lecture;
  static const _pageCount = 4;
  int _currentPage = 0;
  bool _pageSidebarVisible = true;
  final Map<int, List<DrawStroke>> _pageStrokes = {};
  final Map<int, List<_DrawAction>> _pageHistory = {};
  final Map<int, List<_DrawAction>> _pageRedo = {};
  List<DrawStroke> _eraseBeforeSnapshot = [];
  bool _eraseChanged = false;
  DrawStroke? _currentStroke;
  final Map<int, List<ProfMention>> _pageMentions = {};
  Offset? _mentionStart;
  Offset? _mentionCurrent;
  DateTime? _mentionStartTime;
  double _penWidth = 2.5;
  double _highlighterWidth = 16;
  int _lastEraserTool = 2;

  List<DrawStroke> get _strokes => _pageStrokes.putIfAbsent(_currentPage, () {
    final lecture = _lecture;
    if (lecture == null) return [];
    return List.of(NotesStore.instance.pageStrokes(lecture, _currentPage));
  });
  List<ProfMention> get _mentions =>
      _pageMentions.putIfAbsent(_currentPage, () {
        final lecture = _lecture;
        if (lecture == null) return [];
        return List.of(NotesStore.instance.pageMentions(lecture, _currentPage));
      });
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
    final lecture = _lecture;
    if (lecture == null) return;
    NotesStore.instance.updateTypedText(lecture, _typedCtrl.text);
    setState(() => _typedSaving = true);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _typedSaving = false);
    });
  }

  final List<PendingHandwritingBlock> _pendingReview = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_contentLoaded) {
      _contentLoaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Lecture) {
        _lecture = args;
        _typedCtrl.text = NotesStore.instance.contentFor(args).typedText;
        _typedCtrl.addListener(_onTypedChanged);
      }
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
    if (_tool == _mentionTool) {
      _mentionStart = pos;
      _mentionStartTime = DateTime.now();
      setState(() => _mentionCurrent = pos);
      return;
    }
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
        width: _currentTool == DrawTool.highlighter
            ? _highlighterWidth
            : _penWidth,
        points: [pos],
      );
    });
  }

  void _extendStroke(Offset pos) {
    if (_tool == _mentionTool) {
      setState(() => _mentionCurrent = pos);
      return;
    }
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
    if (_tool == _mentionTool) {
      _endMention();
      return;
    }
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
      NotesStore.instance.updatePageStrokes(_lecture!, _currentPage, _strokes);

  // First drag on a spot draws a new border. A later short tap inside an
  // existing border bumps its frequency; a long-press there lowers it again.
  // Threshold is generous (not a tight tap slop) because a real long-press
  // hold accumulates more drift than a quick tap before release.
  static const _mentionTapThreshold = 20.0;
  static const _mentionLongPressDuration = Duration(milliseconds: 500);

  void _endMention() {
    final start = _mentionStart;
    final current = _mentionCurrent;
    final startTime = _mentionStartTime;
    _mentionStart = null;
    _mentionStartTime = null;
    setState(() => _mentionCurrent = null);
    if (start == null || current == null) return;

    if ((current - start).distance < _mentionTapThreshold) {
      ProfMention? hit;
      for (final m in _mentions) {
        if (m.rect.contains(current)) hit = m;
      }
      if (hit == null) return;
      final isLongPress =
          startTime != null &&
          DateTime.now().difference(startTime) >= _mentionLongPressDuration;
      if (isLongPress) {
        _decrementMention(hit);
      } else if (hit.frequency < 3) {
        setState(() => hit!.frequency += 1);
        _persistCurrentPageMentions();
        _showMentionToast('언급 빈도 +1 · ${'⭐' * hit.frequency}');
      }
      return;
    }

    // Dragging over an existing border again (e.g. by mistake) shouldn't
    // stack a duplicate box — treat it as another mention of that region.
    final dragRect = Rect.fromPoints(start, current);
    ProfMention? overlapping;
    for (final m in _mentions) {
      if (m.rect.overlaps(dragRect)) overlapping = m;
    }
    if (overlapping != null) {
      if (overlapping.frequency < 3) {
        setState(() => overlapping!.frequency += 1);
        _persistCurrentPageMentions();
        _showMentionToast('언급 빈도 +1 · ${'⭐' * overlapping.frequency}');
      }
      return;
    }

    setState(() => _mentions.add(ProfMention(start: start, end: current)));
    _persistCurrentPageMentions();
  }

  void _decrementMention(ProfMention mention) {
    if (mention.frequency <= 1) {
      setState(() => _mentions.remove(mention));
      _persistCurrentPageMentions();
      _showMentionToast('표시가 삭제됐어요');
      return;
    }
    setState(() => mention.frequency -= 1);
    _persistCurrentPageMentions();
    _showMentionToast('언급 빈도 -1 · ${'⭐' * mention.frequency}');
  }

  void _persistCurrentPageMentions() => NotesStore.instance.updatePageMentions(
    _lecture!,
    _currentPage,
    _mentions,
  );

  void _showMentionToast(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool get _canUndo => _history.isNotEmpty;
  bool get _canRedo => _redoHistory.isNotEmpty;

  void _selectTool(int tool) {
    setState(() {
      _tool = tool;
      if (tool == 2 || tool == 3) _lastEraserTool = tool;
    });
  }

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
    final lecture = _lecture;
    if (lecture == null) return;
    showNoteDetailMenuSheet(
      context,
      lecture: lecture,
      courseName:
          LearningDomainStore.instance.courseById(lecture.courseId)?.name ?? '',
      hasPendingReview: _pendingReview.isNotEmpty,
      onOpenReview: _openReviewSheet,
      onOpenMaterials: _openMaterialsSheet,
    );
  }

  void _openMaterialsSheet() {
    final lecture = _lecture;
    if (lecture == null) return;
    unawaited(showSessionMaterialsSheet(context, lecture: lecture));
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
    final lecture = _lecture;
    if (lecture == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('필기 정보를 찾을 수 없어요', style: AppTextStyles.bodySmall),
          ),
        ),
      );
    }
    final isDrawing = _mode == _NoteMode.drawing;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          NoteDetailHeader(
            title: '${lecture.week} · ${lecture.title}',
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
              onToolSelected: _selectTool,
              canUndo: _canUndo,
              canRedo: _canRedo,
              onUndo: _undo,
              onRedo: _redo,
              penWidth: _penWidth,
              onPenWidthSelected: (w) => setState(() => _penWidth = w),
              highlighterWidth: _highlighterWidth,
              onHighlighterWidthSelected: (w) =>
                  setState(() => _highlighterWidth = w),
              lastEraserTool: _lastEraserTool,
            ),
            if (_pendingReview.isNotEmpty)
              NoteReviewBanner(
                count: _pendingReview.length,
                onTap: _openReviewSheet,
              ),
          ],
          Expanded(
            child: isDrawing
                ? (context.isTablet ? _buildTabletLayout() : _buildCanvas())
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
      strokes: _strokes,
      currentStroke: _currentStroke,
      mentions: _mentions,
      mentionPreviewRect: _mentionStart != null && _mentionCurrent != null
          ? Rect.fromPoints(_mentionStart!, _mentionCurrent!)
          : null,
      onDrawStart: _startStroke,
      onDrawUpdate: _extendStroke,
      onDrawEnd: _endStroke,
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
