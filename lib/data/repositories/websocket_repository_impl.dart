import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/websocket_repository.dart';
import '../datasources/websocket_data_source.dart';

/// WebSocket 리포지토리 구현
/// Single Responsibility: WebSocket 데이터 소스 래핑
/// Dependency Inversion: 인터페이스에 의존
class WebSocketRepositoryImpl implements WebSocketRepository {
  final WebSocketDataSource dataSource;

  WebSocketRepositoryImpl({required this.dataSource});

  @override
  Future<void> connect(String accessToken) async {
    return await dataSource.connect(accessToken);
  }

  @override
  Future<void> disconnect() async {
    return await dataSource.disconnect();
  }

  @override
  void subscribe(String roomId, Function(ChatMessage) onMessage) {
    dataSource.subscribe(roomId, onMessage);
  }

  @override
  void unsubscribe(String roomId) {
    dataSource.unsubscribe(roomId);
  }

  @override
  void sendMessage({
    required String roomId,
    required String content,
    required String messageType,
    String? metadata,
  }) {
    dataSource.sendMessage(
      roomId: roomId,
      content: content,
      messageType: messageType,
      metadata: metadata,
    );
  }

  @override
  void subscribeToTyping(String roomId, Function(Map<String, dynamic>) onTyping) {
    dataSource.subscribeToTyping(roomId, onTyping);
  }

  @override
  void unsubscribeFromTyping(String roomId) {
    dataSource.unsubscribeFromTyping(roomId);
  }

  @override
  void sendTypingEvent({
    required String roomId,
    required bool isTyping,
  }) {
    dataSource.sendTypingEvent(
      roomId: roomId,
      isTyping: isTyping,
    );
  }

  @override
  Stream<bool> get connectionStateStream => dataSource.connectionStateStream;

  @override
  bool get isConnected => dataSource.isConnected;
}
