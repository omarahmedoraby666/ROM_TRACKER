class ChatThread {
  const ChatThread({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatarPath,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
    required this.isOnline,
    required this.isRead,
  });

  final String id;
  final String name;
  final String subtitle;
  final String avatarPath;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final bool isOnline;
  final bool isRead;

  ChatThread copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? avatarPath,
    String? lastMessage,
    String? lastTime,
    int? unreadCount,
    bool? isOnline,
    bool? isRead,
  }) {
    return ChatThread(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      avatarPath: avatarPath ?? this.avatarPath,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
  });

  final String id;
  final String text;
  final String time;
  final bool isMe;
}
