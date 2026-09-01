import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PanelTitle extends StatelessWidget {
  final String title;
  const PanelTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}
