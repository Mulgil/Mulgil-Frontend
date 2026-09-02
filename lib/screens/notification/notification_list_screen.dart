import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/app_notification.dart';
import '../../constants/routes.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<AppNotification> get _items => MockData.notifications;

  void _open(AppNotification n) {
    final route = switch (n.type) {
      NotificationType.processingComplete => AppRoutes.summary,
      NotificationType.examReminder => AppRoutes.exams,
      NotificationType.postClassReminder => AppRoutes.note,
    };
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text('알림', style: AppTextStyles.h2)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(
                          child: Text(
                            '알림이 없어요',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _NotificationCard(
                            item: _items[i],
                            onTap: () => _open(_items[i]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;
  const _NotificationCard({required this.item, required this.onTap});

  String get _icon => switch (item.type) {
    NotificationType.processingComplete => '✨',
    NotificationType.examReminder => '📅',
    NotificationType.postClassReminder => '✎',
  };

  String get _timeAgo {
    final diff = DateTime.now().difference(item.scheduledAt);
    if (diff.inDays >= 1) return '${diff.inDays}일 전';
    if (diff.inHours >= 1) return '${diff.inHours}시간 전';
    return '방금 전';
  }

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _timeAgo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
