import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TabletHint extends StatelessWidget {
  const TabletHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Text(
        '⭐ 긴 작업이 계속 밀려 실행되지 못하는 기아 현상(starvation)이 발생할 수 있다.',
        style: TextStyle(fontSize: 12.5, color: AppColors.ink80, height: 1.7),
      ),
    );
  }
}
