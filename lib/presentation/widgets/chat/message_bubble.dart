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
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 6),
                  bottomRight: Radius.circular(isMe ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : const Color(0xFF1A1A1A),
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
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              color: Color(0xFF6B7280),
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
                    ? const Color(0xFF667eea).withOpacity(0.1)
                    : const Color(0xFFE5E5EA),
                border: Border.all(
                  color: isMe 
                      ? const Color(0xFF667eea).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                            ? const Color(0xFF667eea)
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isMe 
                              ? const Color(0xFF667eea)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
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
        fontSize: 11,
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w500,
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
