import '../../domain/entities/chat_message.dart';

/// 채팅 메시지 모델
/// Single Responsibility: JSON 직렬화/역직렬화만 담당
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.roomId,
    required super.senderId,
    required super.senderType,
    required super.messageType,
    required super.content,
    super.metadata,
    required super.isRead,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      senderType: SenderType.fromJson(json['senderType'] as String),
      messageType: MessageType.fromJson(json['messageType'] as String),
      content: json['content'] as String,
      metadata: json['metadata'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderType': senderType.toJson(),
      'messageType': messageType.toJson(),
      'content': content,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
