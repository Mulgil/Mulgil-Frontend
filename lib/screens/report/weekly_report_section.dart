import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class WeeklyReportSection extends StatelessWidget {
  const WeeklyReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: '이번 주 리포트'),
        MulgilCard(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: Center(
            child: Text(
              '아직 리포트 데이터가 없어요',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}
