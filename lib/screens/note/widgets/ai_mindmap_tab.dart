import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/resource_upload_api.dart';
import '../../../models/mindmap_graph.dart';
import '../../../theme/app_theme.dart';

class MindmapTab extends StatefulWidget {
  final String centerLabel;
  final MindmapGraph graph;
  final SessionProcessingJob? generationJob;

  const MindmapTab({
    super.key,
    required this.centerLabel,
    required this.graph,
    this.generationJob,
  });

  @override
  State<MindmapTab> createState() => _MindmapTabState();
}

/// A precomputed, canvas-size-independent layout: which node is whose
/// parent, how deep it sits, and its angular position within the radial
/// tree. Recomputed only when the underlying graph changes.
class _GraphLayout {
  static const centerId = '__center__';

  final List<String> order;
  final Map<String, String> labelOf;
  final Map<String, int> depthOf;
  final Map<String, String?> parentOf;
  final Map<String, double> angleOf;
  final int maxDepth;

  const _GraphLayout({
    required this.order,
    required this.labelOf,
    required this.depthOf,
    required this.parentOf,
    required this.angleOf,
    required this.maxDepth,
  });

  static _GraphLayout build(String centerLabel, MindmapGraph graph) {
    final labelOf = <String, String>{centerId: centerLabel};
    for (final node in graph.nodes) {
      labelOf[node.id] = node.label;
    }

    final childrenOf = <String, List<String>>{};
    final hasIncoming = <String>{};
    for (final edge in graph.edges) {
      if (!labelOf.containsKey(edge.from) || !labelOf.containsKey(edge.to)) {
        continue;
      }
      childrenOf.putIfAbsent(edge.from, () => []).add(edge.to);
      hasIncoming.add(edge.to);
    }
    final roots = graph.nodes
        .map((n) => n.id)
        .where((id) => !hasIncoming.contains(id))
        .toList();
    childrenOf[centerId] = roots;

    final depthOf = <String, int>{centerId: 0};
    final parentOf = <String, String?>{centerId: null};
    final order = <String>[centerId];
    final visited = <String>{centerId};
    final queue = Queue<String>()..add(centerId);
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      for (final child in childrenOf[current] ?? const []) {
        if (visited.contains(child)) continue;
        visited.add(child);
        depthOf[child] = depthOf[current]! + 1;
        parentOf[child] = current;
        order.add(child);
        queue.add(child);
      }
    }
    // Any node unreachable from an edge chain (shouldn't normally happen)
    // still gets shown, attached directly under the center.
    for (final node in graph.nodes) {
      if (visited.contains(node.id)) continue;
      visited.add(node.id);
      depthOf[node.id] = 1;
      parentOf[node.id] = centerId;
      order.add(node.id);
      childrenOf.putIfAbsent(centerId, () => []).add(node.id);
    }

    final leafCount = <String, int>{};
    int countLeaves(String id) {
      final kids = childrenOf[id] ?? const [];
      if (kids.isEmpty) return leafCount[id] = 1;
      var sum = 0;
      for (final kid in kids) {
        sum += countLeaves(kid);
      }
      return leafCount[id] = sum;
    }

    countLeaves(centerId);

    final angleOf = <String, double>{centerId: 0};
    void assignAngles(String id, double start, double end) {
      final kids = childrenOf[id] ?? const [];
      if (kids.isEmpty) return;
      final total = leafCount[id]!;
      var cursor = start;
      for (final kid in kids) {
        final span = (end - start) * (leafCount[kid]! / total);
        angleOf[kid] = cursor + span / 2;
        assignAngles(kid, cursor, cursor + span);
        cursor += span;
      }
    }

    assignAngles(centerId, 0, 2 * math.pi);

    final maxDepth = depthOf.values.fold(0, math.max);
    return _GraphLayout(
      order: order,
      labelOf: labelOf,
      depthOf: depthOf,
      parentOf: parentOf,
      angleOf: angleOf,
      maxDepth: maxDepth,
    );
  }
}

class _MindmapTabState extends State<MindmapTab> {
  static const _minScale = 0.6;
  static const _maxScale = 2.2;

  late _GraphLayout _layout;
  Map<String, Offset>? _positions;
  Size? _canvasSize;
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  double _scaleAtGestureStart = 1.0;
  String? _draggingId;

  @override
  void initState() {
    super.initState();
    _layout = _GraphLayout.build(widget.centerLabel, widget.graph);
  }

  @override
  void didUpdateWidget(covariant MindmapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerLabel != widget.centerLabel ||
        oldWidget.graph != widget.graph) {
      _layout = _GraphLayout.build(widget.centerLabel, widget.graph);
      final canvasSize = _canvasSize;
      if (canvasSize != null) {
        _positions = _positionsFromLayout(_layout, canvasSize);
      }
      _panOffset = Offset.zero;
      _scale = 1.0;
    }
  }

  void _ensureLayout(Size size) {
    if (_canvasSize == size) return;
    _canvasSize = size;
    _positions = _positionsFromLayout(_layout, size);
  }

  Map<String, Offset> _positionsFromLayout(_GraphLayout layout, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxDepth = math.max(layout.maxDepth, 1);
    final available = (math.min(size.width, size.height) / 2) - 40;
    final ringStep = available / maxDepth;
    final positions = <String, Offset>{};
    for (final id in layout.order) {
      final depth = layout.depthOf[id]!;
      if (depth == 0) {
        positions[id] = center;
        continue;
      }
      final radius = ringStep * depth;
      final angle = layout.angleOf[id]! - math.pi / 2;
      positions[id] =
          center + Offset.fromDirection(angle, radius) + _jitter(id);
    }
    return positions;
  }

  Offset _jitter(String seed) {
    final h = seed.hashCode & 0x7fffffff;
    final jx = (h % 1000) / 1000.0 * 2 - 1;
    final jy = ((h ~/ 1000) % 1000) / 1000.0 * 2 - 1;
    const range = 10.0;
    return Offset(jx * range, jy * range);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _scaleAtGestureStart = _scale;
    final positions = _positions;
    if (positions == null) return;
    final canvasPoint = (details.localFocalPoint - _panOffset) / _scale;
    String? hit;
    for (final entry in positions.entries) {
      if (entry.key == _GraphLayout.centerId) continue;
      if ((canvasPoint - entry.value).distance <= 20.0) {
        hit = entry.key;
        break;
      }
    }
    _draggingId = hit;
  }

  Offset _clampToCanvas(Offset point) {
    final canvasSize = _canvasSize;
    if (canvasSize == null) return point;
    const marginX = 54.0;
    const marginTop = 16.0;
    const marginBottom = 34.0;
    return Offset(
      point.dx.clamp(marginX, canvasSize.width - marginX),
      point.dy.clamp(marginTop, canvasSize.height - marginBottom),
    );
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final positions = _positions;
    final draggingId = _draggingId;
    if (positions == null) return;
    setState(() {
      if (draggingId != null) {
        final updated =
            positions[draggingId]! + details.focalPointDelta / _scale;
        // Copy-on-write so the painter can tell (by reference) whether node
        // positions actually changed, instead of always repainting.
        _positions = Map.of(positions)..[draggingId] = _clampToCanvas(updated);
      } else {
        _scale = (_scaleAtGestureStart * details.scale).clamp(
          _minScale,
          _maxScale,
        );
        _panOffset += details.focalPointDelta;
      }
    });
  }

  void _resetView() {
    setState(() {
      _panOffset = Offset.zero;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.generationJob;
    final isGenerating = job?.status.isActive == true;
    final isFailed = job?.status == ProcessingJobStatus.failed;
    if (widget.graph.isEmpty || isGenerating || isFailed) {
      final title = isGenerating
          ? '마인드맵 생성 중'
          : isFailed
          ? '마인드맵 생성에 실패했어요.'
          : '마인드맵이 아직 없어요';
      final detail = isGenerating
          ? job!.safeProgressMessage
          : isFailed && job?.retryable == true
          ? '다시 시도해 주세요.'
          : null;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isGenerating)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _ensureLayout(constraints.biggest);
                  final layout = _layout;
                  final positions = _positions!;
                  final canvasSize = _canvasSize!;
                  return GestureDetector(
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onScaleEnd: (_) => setState(() => _draggingId = null),
                    child: ClipRect(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..translateByDouble(
                            _panOffset.dx,
                            _panOffset.dy,
                            0,
                            1,
                          )
                          ..scaleByDouble(_scale, _scale, 1, 1),
                        child: SizedBox(
                          width: canvasSize.width,
                          height: canvasSize.height,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CustomPaint(
                                size: canvasSize,
                                painter: _MindmapLinePainter(
                                  positions: positions,
                                  parentOf: layout.parentOf,
                                ),
                              ),
                              for (final id in layout.order)
                                _buildNode(
                                  positions[id]!,
                                  layout.labelOf[id]!,
                                  layout.depthOf[id]!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _resetView,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      border: Border.all(color: AppColors.border),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.center_focus_weak,
                      size: 16,
                      color: AppColors.ink60,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(Offset pos, String label, int depth) {
    final isCenter = depth == 0;
    const boxWidth = 108.0;
    final dotSize = isCenter
        ? 14.0
        : depth == 1
        ? 11.0
        : 8.0;
    return Positioned(
      left: pos.dx - boxWidth / 2,
      top: pos.dy - dotSize / 2,
      width: boxWidth,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCenter ? AppColors.navy : AppColors.teal,
                boxShadow: [
                  BoxShadow(
                    color: (isCenter ? AppColors.navy : AppColors.teal)
                        .withValues(alpha: 0.35),
                    blurRadius: isCenter ? 10 : 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCenter ? AppColors.ink : AppColors.textMuted,
                fontSize: isCenter ? 12.5 : 11.5,
                fontWeight: isCenter ? FontWeight.w700 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MindmapLinePainter extends CustomPainter {
  final Map<String, Offset> positions;
  final Map<String, String?> parentOf;
  _MindmapLinePainter({required this.positions, required this.parentOf});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.ink40.withValues(alpha: 0.45)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    for (final entry in positions.entries) {
      final parentId = parentOf[entry.key];
      if (parentId == null) continue;
      final parentPos = positions[parentId];
      if (parentPos == null) continue;
      canvas.drawLine(parentPos, entry.value, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MindmapLinePainter old) =>
      !identical(old.positions, positions) ||
      !identical(old.parentOf, parentOf);
}
