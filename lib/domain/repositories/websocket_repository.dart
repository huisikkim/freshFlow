import '../entities/chat_message.dart';

/// WebSocket 리포지토리 인터페이스
/// Interface Segregation: WebSocket 관련 기능만 분리
abstract class WebSocketRepository {
  /// WebSocket 연결
  Future<void> connect(String accessToken);

  /// WebSocket 연결 해제
  Future<void> disconnect();

  /// 채팅방 구독
  void subscribe(String roomId, Function(ChatMessage) onMessage);

  /// 채팅방 구독 해제
  void unsubscribe(String roomId);

  /// 메시지 전송
  void sendMessage({
    required String roomId,
    required String content,
    required String messageType,
    String? metadata,
  });

  /// 타이핑 이벤트 구독
  void subscribeToTyping(String roomId, Function(Map<String, dynamic>) onTyping);

  /// 타이핑 이벤트 구독 해제
  void unsubscribeFromTyping(String roomId);

  /// 타이핑 이벤트 전송
  void sendTypingEvent({
    required String roomId,
    required bool isTyping,
  });

  /// 연결 상태 스트림
  Stream<bool> get connectionStateStream;

  /// 현재 연결 상태
  bool get isConnected;
}
