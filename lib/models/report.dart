import 'package:flutter/material.dart';

class SubjectRecord {
  final String name;
  final double hours;
  final Color color;

  const SubjectRecord({
    required this.name,
    required this.hours,
    required this.color,
  });
}

class Achievement {
  final String icon;
  final String label;
  final String desc;

  const Achievement({
    required this.icon,
    required this.label,
    required this.desc,
  });
}
