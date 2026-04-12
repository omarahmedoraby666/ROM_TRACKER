enum AppNotificationType {
  session,
  message,
  reminder,
  system,
}

enum AppNotificationTarget {
  home,
  sessions,
  chat,
  system,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    required this.target,
    this.threadId,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final AppNotificationType type;
  final AppNotificationTarget target;
  final String? threadId;
  final bool isRead;

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    AppNotificationType? type,
    AppNotificationTarget? target,
    String? threadId,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      target: target ?? this.target,
      threadId: threadId ?? this.threadId,
      isRead: isRead ?? this.isRead,
    );
  }
}
