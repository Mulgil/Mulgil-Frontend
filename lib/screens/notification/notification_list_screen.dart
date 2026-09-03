import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/app_services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/app_notification.dart';
import '../../constants/routes.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late Future<List<AppNotification>> _notificationsLoad;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _notificationsLoad = _loadNotifications();
  }

  Future<List<AppNotification>> _loadNotifications() async {
    try {
      _loadError = null;
      return await AppServices.learningDomain.listNotifications();
    } on ApiException catch (error) {
      _loadError = error.message;
    } on Exception {
      _loadError = '알림을 불러오지 못했어요.';
    }
    return const [];
  }

  void _retry() {
    setState(() => _notificationsLoad = _loadNotifications());
  }

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
                  child: FutureBuilder<List<AppNotification>>(
                    future: _notificationsLoad,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final error = _loadError;
                      if (error != null) {
                        return _NotificationStatusNotice(
                          message: error,
                          onRetry: _retry,
                        );
                      }
                      final items = snapshot.data ?? const [];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            '알림이 없어요',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _NotificationCard(
                          item: items[i],
                          onTap: () => _open(items[i]),
                        ),
                      );
                    },
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

  IconData get _icon => switch (item.type) {
    NotificationType.processingComplete => Icons.auto_awesome_outlined,
    NotificationType.examReminder => Icons.event_outlined,
    NotificationType.postClassReminder => Icons.edit_note_outlined,
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
          Icon(_icon, size: 18, color: AppColors.navy),
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

class _NotificationStatusNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NotificationStatusNotice({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
