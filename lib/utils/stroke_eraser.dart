import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/draw_stroke.dart';

/// Pure geometry for the eraser tool: finds strokes touched by an eraser
/// circle and splits each one into the surviving pieces either side of the
/// erased gap.
class StrokeEraser {
  const StrokeEraser._();

  static List<DrawStroke> strokesNear(
    List<DrawStroke> strokes,
    Offset pos,
    double radius,
  ) {
    return strokes.where((s) => _strokeNearPoint(s, pos, radius)).toList();
  }

  // Walks the stroke's points, cutting exactly at the eraser circle's boundary
  // (via circle/segment intersection) so straight, sparsely-sampled strokes still
  // split into clean surviving pieces either side of the erased gap.
  static List<DrawStroke> erasePortion(
    DrawStroke stroke,
    Offset pos,
    double radius,
  ) {
    final pts = stroke.points;
    if (pts.length < 2) {
      return (pts.isNotEmpty && (pts.first - pos).distance < radius)
          ? const []
          : [stroke];
    }
    bool inside(Offset p) => (p - pos).distance < radius;

    final pieces = <DrawStroke>[];
    var current = <Offset>[];
    void flush() {
      if (current.length >= 2) {
        pieces.add(
          DrawStroke(
            tool: stroke.tool,
            color: stroke.color,
            width: stroke.width,
            points: List.of(current),
          ),
        );
      }
      current = [];
    }

    if (!inside(pts.first)) current.add(pts.first);

    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final aIn = inside(a);
      final bIn = inside(b);
      final ts = _circleSegmentIntersections(pos, radius, a, b);

      if (aIn && bIn) continue;

      if (!aIn && !bIn) {
        if (ts.length == 2) {
          current.add(a + (b - a) * ts[0]);
          flush();
          current.add(a + (b - a) * ts[1]);
        }
        current.add(b);
        continue;
      }

      final t = ts.isNotEmpty ? ts.first : (aIn ? 0.0 : 1.0);
      final boundary = a + (b - a) * t;
      if (aIn) {
        current.add(boundary);
        current.add(b);
      } else {
        current.add(boundary);
        flush();
      }
    }
    flush();
    return pieces;
  }

  static List<double> _circleSegmentIntersections(
    Offset center,
    double radius,
    Offset a,
    Offset b,
  ) {
    final d = b - a;
    final f = a - center;
    final aCoef = d.dx * d.dx + d.dy * d.dy;
    if (aCoef == 0) return const [];
    final bCoef = 2 * (f.dx * d.dx + f.dy * d.dy);
    final cCoef = f.dx * f.dx + f.dy * f.dy - radius * radius;
    final discriminant = bCoef * bCoef - 4 * aCoef * cCoef;
    if (discriminant < 0) return const [];
    final sqrtDisc = math.sqrt(discriminant);
    final t1 = (-bCoef - sqrtDisc) / (2 * aCoef);
    final t2 = (-bCoef + sqrtDisc) / (2 * aCoef);
    final result = <double>[];
    if (t1 >= 0 && t1 <= 1) result.add(t1);
    if (t2 >= 0 && t2 <= 1 && t2 != t1) result.add(t2);
    result.sort();
    return result;
  }

  static bool _strokeNearPoint(DrawStroke stroke, Offset pos, double radius) {
    if (stroke.points.length < 2) {
      return stroke.points.any((p) => (p - pos).distance < radius);
    }
    for (var i = 0; i < stroke.points.length - 1; i++) {
      if (_distanceToSegment(pos, stroke.points[i], stroke.points[i + 1]) <
          radius) {
        return true;
      }
    }
    return false;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSquared == 0) return (p - a).distance;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / lengthSquared)
        .clamp(0.0, 1.0);
    final projection = a + ab * t;
    return (p - projection).distance;
  }
}
