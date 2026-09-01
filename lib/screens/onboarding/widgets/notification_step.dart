import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

// ── Notification Setup ───────────────────────────────

class NotificationStep extends StatefulWidget {
  final VoidCallback onNext;
  const NotificationStep({super.key, required this.onNext});

  @override
  State<NotificationStep> createState() => _NotificationStepState();
}

class _NotificationStepState extends State<NotificationStep> {
  bool _postClass = true;
  bool _examReminder = true;
  bool _processingComplete = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '온보딩 1/2',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('학습 알림을 설정해주세요', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                const Text(
                  '꼭 필요한 순간에만, 놓치지 않게 알려드려요',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _NotificationToggleTile(
                        icon: '📝',
                        title: '수업 후 필기 리마인더',
                        subtitle: '수업이 끝나면 필기를 시작할 때예요',
                        value: _postClass,
                        onChanged: (v) => setState(() => _postClass = v),
                      ),
                      const SizedBox(height: 10),
                      _NotificationToggleTile(
                        icon: '📅',
                        title: '시험 D-day 알림',
                        subtitle: '다가오는 시험 일정을 미리 알려드려요',
                        value: _examReminder,
                        onChanged: (v) => setState(() => _examReminder = v),
                      ),
                      const SizedBox(height: 10),
                      _NotificationToggleTile(
                        icon: '✨',
                        title: 'AI 요약 완료 알림',
                        subtitle: '필기·자료 정리가 끝나면 알려드려요',
                        value: _processingComplete,
                        onChanged: (v) =>
                            setState(() => _processingComplete = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MulgilButton(label: '다음', onTap: widget.onNext),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.teal,
          ),
        ],
      ),
    );
  }
}
