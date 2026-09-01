import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class WrongAnswerEmptyBox extends StatelessWidget {
  const WrongAnswerEmptyBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: MulgilCard(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            '해당하는 오답이 없어요',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
