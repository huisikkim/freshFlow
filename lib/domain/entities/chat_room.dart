import 'package:equatable/equatable.dart';

/// 채팅방 엔티티
/// Single Responsibility: 채팅방 데이터만 표현
class ChatRoom extends Equatable {
  final int id;
  final String roomId;
  final String storeId;
  final String distributorId;
  final String storeName;
  final String distributorName;
  final bool isActive;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.roomId,
    required this.storeId,
    required this.distributorId,
    required this.storeName,
    required this.distributorName,
    required this.isActive,
    this.lastMessageAt,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        storeId,
        distributorId,
        storeName,
        distributorName,
        isActive,
        lastMessageAt,
        unreadCount,
      ];
}
