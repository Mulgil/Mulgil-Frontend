import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/resource_upload_api.dart';
import '../../../theme/app_theme.dart';

class MindmapTab extends StatefulWidget {
  final String centerLabel;
  final List<String> nodeLabels;
  final SessionProcessingJob? generationJob;

  const MindmapTab({
    super.key,
    required this.centerLabel,
    required this.nodeLabels,
    this.generationJob,
  });

  @override
  State<MindmapTab> createState() => _MindmapTabState();
}

class _MindmapTabState extends State<MindmapTab> {
  static const _canvasSize = Size(560, 420);
  static const _baseRadius = 110.0;
  static const _minScale = 0.6;
  static const _maxScale = 2.2;

  late List<Offset> _positions;
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  double _scaleAtGestureStart = 1.0;
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _positions = _initialPositions();
  }

  @override
  void didUpdateWidget(covariant MindmapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerLabel != widget.centerLabel ||
        oldWidget.nodeLabels.join('|') != widget.nodeLabels.join('|')) {
      _positions = _initialPositions();
      _panOffset = Offset.zero;
      _scale = 1.0;
    }
  }

  List<String> _visibleLabels() =>
      widget.nodeLabels.where((label) => label.trim().isNotEmpty).toList();

  List<Offset> _initialPositions() {
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final labels = _visibleLabels();
    final n = labels.length;
    final radius = n <= 4 ? _baseRadius : (_baseRadius + (n - 4) * 14.0);
    return [
      center,
      for (var i = 0; i < n; i++)
        center +
            _jitter(
              labels[i],
              Offset.fromDirection((2 * math.pi * i / n) - math.pi / 2, radius),
            ),
    ];
  }

  Offset _jitter(String seed, Offset base) {
    final h = seed.hashCode & 0x7fffffff;
    final jx = (h % 1000) / 1000.0 * 2 - 1;
    final jy = ((h ~/ 1000) % 1000) / 1000.0 * 2 - 1;
    const range = 18.0;
    return base + Offset(jx * range, jy * range);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _scaleAtGestureStart = _scale;
    final canvasPoint = (details.localFocalPoint - _panOffset) / _scale;
    int? hit;
    for (var i = 0; i < _positions.length; i++) {
      final hitRadius = i == 0 ? 26.0 : 20.0;
      if ((canvasPoint - _positions[i]).distance <= hitRadius) {
        hit = i;
        break;
      }
    }
    _draggingIndex = hit;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (_draggingIndex != null) {
        _positions[_draggingIndex!] += details.focalPointDelta / _scale;
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
    final visibleLabels = _visibleLabels();
    final job = widget.generationJob;
    final isGenerating = job?.status.isActive == true;
    final isFailed = job?.status == ProcessingJobStatus.failed;
    if (visibleLabels.isEmpty || isGenerating || isFailed) {
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          height: 340,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: (_) => setState(() => _draggingIndex = null),
                  child: ClipRect(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translateByDouble(_panOffset.dx, _panOffset.dy, 0, 1)
                        ..scaleByDouble(_scale, _scale, 1, 1),
                      child: SizedBox(
                        width: _canvasSize.width,
                        height: _canvasSize.height,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomPaint(
                              size: _canvasSize,
                              painter: _MindmapLinePainter(
                                positions: _positions,
                              ),
                            ),
                            for (var i = 0; i < _positions.length; i++)
                              _buildNode(
                                i,
                                i == 0
                                    ? widget.centerLabel
                                    : visibleLabels[i - 1],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
      ),
    );
  }

  Widget _buildNode(int index, String label) {
    final isCenter = index == 0;
    final pos = _positions[index];
    const boxWidth = 108.0;
    final dotSize = isCenter ? 14.0 : 9.0;
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
  final List<Offset> positions;
  _MindmapLinePainter({required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.ink40.withValues(alpha: 0.45)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final center = positions.first;
    for (var i = 1; i < positions.length; i++) {
      canvas.drawLine(center, positions[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MindmapLinePainter old) => true;
}
