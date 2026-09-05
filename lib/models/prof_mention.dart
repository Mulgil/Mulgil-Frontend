import 'package:flutter/material.dart';

class ProfMention {
  final Offset start;
  final Offset end;
  int frequency;

  ProfMention({required this.start, required this.end, this.frequency = 1});

  Rect get rect => Rect.fromPoints(start, end);
}
