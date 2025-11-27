import '../../domain/entities/chat_message.dart';

/// WebSocket 데이터 소스 인터페이스
/// Interface Segregation: WebSocket 통신만 정의
abstract class WebSocketDataSource {
  Future<void> connect(String accessToken);
  Future<void> disconnect();
  void subscribe(String roomId, Function(ChatMessage) onMessage);
  void unsubscribe(String roomId);
  void sendMessage({
    required String roomId,
    required String content,
    required String messageType,
    String? metadata,
  });
  Stream<bool> get connectionStateStream;
  bool get isConnected;
}
