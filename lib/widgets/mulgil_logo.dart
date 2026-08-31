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

class MulgilWordmark extends StatelessWidget {
  final double fontSize;
  final Color color;
  const MulgilWordmark({
    super.key,
    this.fontSize = 48,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'mulgil',
      style: GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -1,
      ),
    );
  }
}
