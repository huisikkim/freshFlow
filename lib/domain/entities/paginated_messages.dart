import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// 페이징된 메시지 목록
/// Single Responsibility: 페이징 정보와 메시지 목록 관리
class PaginatedMessages extends Equatable {
  final List<ChatMessage> messages;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool isLast;
  final bool isFirst;
  final bool isEmpty;

  const PaginatedMessages({
    required this.messages,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
    required this.isFirst,
    required this.isEmpty,
  });

  @override
  List<Object?> get props => [
        messages,
        pageNumber,
        pageSize,
        totalPages,
        totalElements,
        isLast,
        isFirst,
        isEmpty,
      ];
}
