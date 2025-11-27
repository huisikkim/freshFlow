import '../../domain/entities/chat_room.dart';

/// 채팅방 모델
/// Single Responsibility: JSON 직렬화/역직렬화만 담당
class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.roomId,
    required super.storeId,
    required super.distributorId,
    required super.storeName,
    required super.distributorName,
    required super.isActive,
    super.lastMessageAt,
    required super.unreadCount,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as int,
      roomId: json['roomId'] as String,
      storeId: json['storeId'] as String,
      distributorId: json['distributorId'] as String,
      storeName: json['storeName'] as String,
      distributorName: json['distributorName'] as String,
      isActive: json['isActive'] as bool,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      unreadCount: json['unreadCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'storeId': storeId,
      'distributorId': distributorId,
      'storeName': storeName,
      'distributorName': distributorName,
      'isActive': isActive,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
