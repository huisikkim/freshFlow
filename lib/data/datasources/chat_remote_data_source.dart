import '../models/chat_room_model.dart';
import '../models/paginated_messages_model.dart';

/// 채팅 원격 데이터 소스 인터페이스
/// Interface Segregation: REST API 관련 기능만 정의
abstract class ChatRemoteDataSource {
  Future<ChatRoomModel> createOrGetChatRoom({
    required String storeId,
    required String distributorId,
  });

  Future<List<ChatRoomModel>> getChatRooms();

  Future<PaginatedMessagesModel> getMessages({
    required String roomId,
    int page = 0,
    int size = 50,
  });

  Future<int> getUnreadCount(String roomId);

  Future<void> markAsRead(String roomId);
}
