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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFD4AF37) : const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.black : const Color(0xFFE5E5E7),
                  fontSize: 15,
                  height: 1.4,
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3C).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              color: Color(0xFF98989D),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMe 
                    ? const Color(0xFFD4AF37).withOpacity(0.2)
                    : const Color(0xFF3A3A3C),
                border: Border.all(
                  color: isMe 
                      ? const Color(0xFFD4AF37).withOpacity(0.5)
                      : const Color(0xFF4A4A4C),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForMessageType(),
                        size: 18,
                        color: isMe 
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFF98989D),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isMe 
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF98989D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE5E5E7),
                      height: 1.4,
                    ),
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
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF98989D),
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
