import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/chat_message.dart';

/// 메시지 말풍선 위젯
/// Single Responsibility: 메시지 UI만 담당
/// Open/Closed: 메시지 타입별 UI 확장 가능
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // 메시지 타입에 따라 다른 UI 표시
    switch (message.messageType) {
      case MessageType.system:
        return _buildSystemMessage(context);
      case MessageType.orderInquiry:
      case MessageType.quoteRequest:
      case MessageType.quoteResponse:
        return _buildSpecialMessage(context);
      case MessageType.text:
      default:
        return _buildTextMessage(context);
    }
  }

  Widget _buildTextMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) ...[
            _buildTime(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (!isMe) ...[
            const SizedBox(width: 8),
            _buildTime(),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) ...[
            _buildTime(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue[50] : Colors.grey[100],
                border: Border.all(
                  color: isMe ? Colors.blue : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForMessageType(),
                        size: 16,
                        color: isMe ? Colors.blue : Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.blue : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          if (!isMe) ...[
            const SizedBox(width: 8),
            _buildTime(),
          ],
        ],
      ),
    );
  }

  Widget _buildTime() {
    return Text(
      DateFormat('HH:mm').format(message.createdAt),
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
      ),
    );
  }

  IconData _getIconForMessageType() {
    switch (message.messageType) {
      case MessageType.orderInquiry:
        return Icons.shopping_cart;
      case MessageType.quoteRequest:
        return Icons.request_quote;
      case MessageType.quoteResponse:
        return Icons.receipt;
      default:
        return Icons.message;
    }
  }

  String _getTypeLabel() {
    switch (message.messageType) {
      case MessageType.orderInquiry:
        return '주문 문의';
      case MessageType.quoteRequest:
        return '견적 요청';
      case MessageType.quoteResponse:
        return '견적 응답';
      default:
        return '';
    }
  }
}
