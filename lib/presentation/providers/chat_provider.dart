import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/repositories/websocket_repository.dart';
import '../../domain/usecases/create_or_get_chat_room.dart';
import '../../domain/usecases/get_chat_rooms.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/mark_messages_as_read.dart';
import '../../domain/usecases/send_message.dart';

/// 채팅 Provider
/// Single Responsibility: 채팅 관련 상태 관리만 담당
class ChatProvider with ChangeNotifier {
  final GetChatRooms getChatRooms;
  final CreateOrGetChatRoom createOrGetChatRoom;
  final GetMessages getMessages;
  final MarkMessagesAsRead markMessagesAsRead;
  final SendMessage sendMessage;
  final WebSocketRepository webSocketRepository;

  ChatProvider({
    required this.getChatRooms,
    required this.createOrGetChatRoom,
    required this.getMessages,
    required this.markMessagesAsRead,
    required this.sendMessage,
    required this.webSocketRepository,
  });

  // 상태
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  ChatRoom? _currentRoom;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMoreMessages = true;
  bool _isConnected = false;

  // Getters
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  ChatRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isConnected => _isConnected;

  /// WebSocket 연결
  Future<void> connectWebSocket(String accessToken) async {
    try {
      await webSocketRepository.connect(accessToken);
      _isConnected = true;
      notifyListeners();

      // 연결 상태 모니터링
      webSocketRepository.connectionStateStream.listen((connected) {
        _isConnected = connected;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// WebSocket 연결 해제
  Future<void> disconnectWebSocket() async {
    await webSocketRepository.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  /// 채팅방 목록 로드
  Future<void> loadChatRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getChatRooms();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (rooms) {
        _chatRooms = rooms;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 채팅방 생성 또는 조회
  Future<ChatRoom?> createOrGetRoom({
    required String storeId,
    required String distributorId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createOrGetChatRoom(
      storeId: storeId,
      distributorId: distributorId,
    );

    ChatRoom? room;
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (chatRoom) {
        room = chatRoom;
        _currentRoom = chatRoom;
        _isLoading = false;
        notifyListeners();
      },
    );

    return room;
  }

  /// 메시지 로드 (페이징)
  Future<void> loadMessages(String roomId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _messages = [];
      _hasMoreMessages = true;
    }

    if (!_hasMoreMessages) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMessages(
      roomId: roomId,
      page: _currentPage,
      size: 50,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (paginatedMessages) {
        // 최신 메시지가 먼저 오므로 역순으로 추가
        _messages.insertAll(0, paginatedMessages.messages.reversed);
        _hasMoreMessages = !paginatedMessages.isLast;
        _currentPage++;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 채팅방 입장 (구독 + 읽음 처리)
  Future<void> enterRoom(String roomId, String accessToken) async {
    // WebSocket이 연결되지 않았으면 연결 시도
    if (!_isConnected) {
      try {
        await connectWebSocket(accessToken);
      } catch (e) {
        _error = 'WebSocket 연결 실패: ${e.toString()}';
        notifyListeners();
      }
    }

    if (_isConnected) {
      // WebSocket 구독
      try {
        webSocketRepository.subscribe(roomId, (message) {
          _messages.add(message);
          notifyListeners();
        });
      } catch (e) {
        _error = 'WebSocket 구독 실패: ${e.toString()}';
        notifyListeners();
      }
    }

    // 읽음 처리
    await markMessagesAsRead(roomId);
  }

  /// 채팅방 퇴장 (구독 해제)
  void leaveRoom(String roomId) {
    if (_isConnected) {
      webSocketRepository.unsubscribe(roomId);
    }
    _currentRoom = null;
    _messages = [];
    _currentPage = 0;
    _hasMoreMessages = true;
    notifyListeners();
  }

  /// 메시지 전송
  Future<void> sendTextMessage({
    required String roomId,
    required String content,
    String messageType = 'TEXT',
    String? metadata,
  }) async {
    // WebSocket 연결 확인
    if (!_isConnected) {
      _error = 'WebSocket이 연결되지 않았습니다. 잠시 후 다시 시도해주세요.';
      notifyListeners();
      return;
    }

    final result = await sendMessage(
      roomId: roomId,
      content: content,
      messageType: messageType,
      metadata: metadata,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) {
        // 메시지 전송 성공 (WebSocket으로 수신됨)
      },
    );
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
