class ChatSession {
  final int id;
  final int? userId;
  final String? guestId;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    this.userId,
    this.guestId,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.messages = const [],
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userId: json['user_id'],
      guestId: json['guest_id'],
      title: json['title'] ?? 'Chat',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      messages: json['messages'] != null
          ? (json['messages'] as List).map((i) => ChatMessage.fromJson(i)).toList()
          : [],
    );
  }
}

class ChatMessage {
  final int? id;
  final int? chatSessionId;
  final String role; // 'user' or 'model'
  final String content;
  final bool isEscalated;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isUser;

  ChatMessage({
    this.id,
    this.chatSessionId,
    required this.role,
    required this.content,
    this.isEscalated = false,
    this.createdAt,
    this.updatedAt,
    required this.isUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role = json['role'] ?? 'user';
    final isEscalated = json['is_escalated'] == true ||
        json['is_escalated'] == 1 ||
        json['is_escalated'] == '1';
    return ChatMessage(
      id: json['id'],
      chatSessionId: json['chat_session_id'],
      role: role,
      content: json['content'] ?? '',
      isEscalated: isEscalated,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isUser: role == 'user',
    );
  }
}
