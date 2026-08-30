import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../models/app_notification.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<AppNotification> get _items => MockData.notifications;

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < MockData.notifications.length; i++) {
        MockData.notifications[i] = MockData.notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _open(AppNotification n) {
    setState(() {
      final i = MockData.notifications.indexWhere((item) => item.id == n.id);
      MockData.notifications[i] = n.copyWith(isRead: true);
    });
    final route = switch (n.type) {
      NotificationType.processingComplete => '/summary',
      NotificationType.examReminder => '/exams',
      NotificationType.postClassReminder => '/note',
    };
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('알림', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                  TextButton(onPressed: _markAllRead, child: const Text('모두 읽음', style: TextStyle(fontSize: 12, color: AppColors.tealDark, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _items.isEmpty
                    ? const Center(child: Text('알림이 없어요', style: TextStyle(color: AppColors.textMuted)))
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _NotificationCard(item: _items[i], onTap: () => _open(_items[i])),
                      ),
              ),
            ],
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
    return Material(
      color: item.isRead ? Colors.white : const Color(0xFFF7FBFB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: TextStyle(fontSize: 13.5, fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(item.body, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text(_timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}
