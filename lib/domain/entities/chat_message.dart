import 'package:equatable/equatable.dart';

/// 메시지 타입 열거형
/// Open/Closed: 새로운 타입 추가 시 확장 가능
enum MessageType {
  text,
  orderInquiry,
  quoteRequest,
  quoteResponse,
  system;

  String toJson() {
    switch (this) {
      case MessageType.text:
        return 'TEXT';
      case MessageType.orderInquiry:
        return 'ORDER_INQUIRY';
      case MessageType.quoteRequest:
        return 'QUOTE_REQUEST';
      case MessageType.quoteResponse:
        return 'QUOTE_RESPONSE';
      case MessageType.system:
        return 'SYSTEM';
    }
  }

  static MessageType fromJson(String value) {
    switch (value) {
      case 'TEXT':
        return MessageType.text;
      case 'ORDER_INQUIRY':
        return MessageType.orderInquiry;
      case 'QUOTE_REQUEST':
        return MessageType.quoteRequest;
      case 'QUOTE_RESPONSE':
        return MessageType.quoteResponse;
      case 'SYSTEM':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

/// 발신자 타입
enum SenderType {
  store,
  distributor;

  String toJson() {
    switch (this) {
      case SenderType.store:
        return 'STORE';
      case SenderType.distributor:
        return 'DISTRIBUTOR';
    }
  }

  static SenderType fromJson(String value) {
    switch (value) {
      case 'STORE':
        return SenderType.store;
      case 'DISTRIBUTOR':
        return SenderType.distributor;
      default:
        return SenderType.store;
    }
  }
}

/// 채팅 메시지 엔티티
/// Single Responsibility: 메시지 데이터만 표현
class ChatMessage extends Equatable {
  final int id;
  final String roomId;
  final String senderId;
  final SenderType senderType;
  final MessageType messageType;
  final String content;
  final String? metadata;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderType,
    required this.messageType,
    required this.content,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderId,
        senderType,
        messageType,
        content,
        metadata,
        isRead,
        createdAt,
      ];
}
