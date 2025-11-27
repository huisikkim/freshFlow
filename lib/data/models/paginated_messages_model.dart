import '../../domain/entities/paginated_messages.dart';
import 'chat_message_model.dart';

/// 페이징된 메시지 모델
/// Single Responsibility: JSON 직렬화/역직렬화만 담당
class PaginatedMessagesModel extends PaginatedMessages {
  const PaginatedMessagesModel({
    required super.messages,
    required super.pageNumber,
    required super.pageSize,
    required super.totalPages,
    required super.totalElements,
    required super.isLast,
    required super.isFirst,
    required super.isEmpty,
  });

  factory PaginatedMessagesModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>;
    final messages = content
        .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final pageable = json['pageable'] as Map<String, dynamic>;

    return PaginatedMessagesModel(
      messages: messages,
      pageNumber: pageable['pageNumber'] as int,
      pageSize: pageable['pageSize'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      isLast: json['last'] as bool,
      isFirst: json['first'] as bool,
      isEmpty: json['empty'] as bool,
    );
  }
}
