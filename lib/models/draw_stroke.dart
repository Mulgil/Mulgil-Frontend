import 'package:flutter/material.dart';

enum DrawTool { pen, highlighter, eraser }

class DrawStroke {
  final DrawTool tool;
  final Color color;
  final double width;
  final List<Offset> points;

  DrawStroke({
    required this.tool,
    required this.color,
    required this.width,
    List<Offset>? points,
  }) : points = points ?? [];
}
