enum NotificationType { postClassReminder, processingComplete, examReminder }

enum NotificationStatus { scheduled, sent, failed, cancelled }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String deepLink;
  final NotificationStatus status;
  final DateTime scheduledAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.deepLink,
    required this.status,
    required this.scheduledAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      deepLink: deepLink,
      status: status,
      scheduledAt: scheduledAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
