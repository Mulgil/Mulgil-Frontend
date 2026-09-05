import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MulgilBubbles extends StatelessWidget {
  final double size;
  final Color color;
  const MulgilBubbles({super.key, this.size = 52, this.color = AppColors.teal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.88,
      child: CustomPaint(painter: _BubblesPainter(color: color)),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  final Color color;
  _BubblesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(
      Offset(w * 0.13, h * 0.87),
      w * 0.07,
      p..color = color.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      Offset(w * 0.37, h * 0.64),
      w * 0.11,
      p..color = color.withValues(alpha: 0.75),
    );
    canvas.drawCircle(Offset(w * 0.71, h * 0.30), w * 0.17, p..color = color);
  }

  @override
  bool shouldRepaint(_) => false;
}

// "mulgil" wordmark with the dot of the "i" replaced by the brand's dot-trail
// mark (three circles growing in a diagonal) — a direct visual bridge between
// the wordmark and the standalone icon (MulgilBubbles). Geometry below mirrors
// the design handoff 1:1, scaled from its 56px reference size.
class MulgilWordmark extends StatelessWidget {
  final double fontSize;
  final Color color;
  const MulgilWordmark({
    super.key,
    this.fontSize = 48,
    this.color = Colors.white,
  });

  static const _refSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final scale = fontSize / _refSize;
    final textStyle = kIsWeb
        ? TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          )
        : GoogleFonts.nunito(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('mulg', style: textStyle),
        SizedBox(width: scale),
        _IDotGlyph(scale: scale, color: color),
        SizedBox(width: scale),
        Text('l', style: textStyle),
      ],
    );
  }
}

class _IDotGlyph extends StatelessWidget {
  final double scale;
  final Color color;
  const _IDotGlyph({required this.scale, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MulgilWordmark._refSize * scale,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 18 * scale,
            height: 16 * scale,
            child: CustomPaint(painter: _IDotIconPainter(color: color)),
          ),
          SizedBox(height: 6 * scale),
          Container(
            width: 8 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3 * scale),
            ),
          ),
        ],
      ),
    );
  }
}

// Draws the dot-trail mark's 140x140 viewBox (circles at (18,122) r10,
// (52,90) r16, (100,42) r24) into the target box the way an <svg
// preserveAspectRatio="xMidYMid meet"> would — uniform scale, centered.
class _IDotIconPainter extends CustomPainter {
  final Color color;
  const _IDotIconPainter({required this.color});

  static const _viewBox = 140.0;
  static const _circles = [
    (cx: 18.0, cy: 122.0, r: 10.0),
    (cx: 52.0, cy: 90.0, r: 16.0),
    (cx: 100.0, cy: 42.0, r: 24.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width < size.height
        ? size.width / _viewBox
        : size.height / _viewBox;
    final dx = (size.width - _viewBox * s) / 2;
    final dy = (size.height - _viewBox * s) / 2;
    final paint = Paint()..color = color;
    for (final c in _circles) {
      canvas.drawCircle(Offset(dx + c.cx * s, dy + c.cy * s), c.r * s, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IDotIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
