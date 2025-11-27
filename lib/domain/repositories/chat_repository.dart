import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_room.dart';
import '../entities/chat_message.dart';
import '../entities/paginated_messages.dart';

/// 채팅 리포지토리 인터페이스
/// Interface Segregation & Dependency Inversion:
/// 추상화에 의존하며, 필요한 기능만 정의
abstract class ChatRepository {
  /// 채팅방 생성 또는 조회
  Future<Either<Failure, ChatRoom>> createOrGetChatRoom({
    required String storeId,
    required String distributorId,
  });

  /// 내 채팅방 목록 조회
  Future<Either<Failure, List<ChatRoom>>> getChatRooms();

  /// 채팅 메시지 목록 조회 (페이징)
  Future<Either<Failure, PaginatedMessages>> getMessages({
    required String roomId,
    int page = 0,
    int size = 50,
  });

  /// 읽지 않은 메시지 수 조회
  Future<Either<Failure, int>> getUnreadCount(String roomId);

  /// 메시지 읽음 처리
  Future<Either<Failure, void>> markAsRead(String roomId);

  /// WebSocket 메시지 전송
  Future<Either<Failure, void>> sendMessage({
    required String roomId,
    required String content,
    required String messageType,
    String? metadata,
  });
}
