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
  String? _subscribedRoomId; // 현재 구독 중인 채팅방 ID
  
  // 타이핑 인디케이터 상태
  bool _isOtherUserTyping = false;
  String? _typingUserName;

  // Getters
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  ChatRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isConnected => _isConnected;
  bool get isOtherUserTyping => _isOtherUserTyping;
  String? get typingUserName => _typingUserName;

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
    print('=== enterRoom 시작 ===');
    print('roomId: $roomId');
    print('현재 구독 중인 방: $_subscribedRoomId');
    print('WebSocket 연결 상태: $_isConnected');
    
    // 이미 같은 채팅방을 구독 중이면 리턴
    if (_subscribedRoomId == roomId && _isConnected) {
      print('이미 같은 채팅방 구독 중');
      return;
    }

    // 이전 채팅방 구독 해제
    if (_subscribedRoomId != null && _isConnected) {
      print('이전 채팅방 구독 해제: $_subscribedRoomId');
      webSocketRepository.unsubscribe(_subscribedRoomId!);
    }

    // WebSocket 재연결 (새로운 토큰으로 연결하기 위해 항상 재연결)
    try {
      if (_isConnected) {
        print('기존 WebSocket 연결 해제 중...');
        await disconnectWebSocket();
        // 연결 해제 후 잠시 대기
        await Future.delayed(const Duration(milliseconds: 300));
      }
      print('새로운 WebSocket 연결 시도...');
      await connectWebSocket(accessToken);
      print('WebSocket 연결 완료');
    } catch (e) {
      print('❌ WebSocket 연결 실패: $e');
      _error = 'WebSocket 연결 실패: ${e.toString()}';
      notifyListeners();
      return;
    }

    if (_isConnected) {
      // WebSocket 메시지 구독
      try {
        webSocketRepository.subscribe(roomId, (message) {
          // 중복 메시지 방지: 이미 존재하는 메시지인지 확인
          final isDuplicate = _messages.any((m) => m.id == message.id);
          if (!isDuplicate) {
            _messages.add(message);
            notifyListeners();
          }
        });
        _subscribedRoomId = roomId;
      } catch (e) {
        _error = 'WebSocket 구독 실패: ${e.toString()}';
        notifyListeners();
      }

      // 타이핑 이벤트 구독
      try {
        webSocketRepository.subscribeToTyping(roomId, (typingEvent) {
          _handleTypingEvent(typingEvent);
        });
        print('✅ 타이핑 이벤트 구독 완료: $roomId');
      } catch (e) {
        print('⚠️ 타이핑 이벤트 구독 실패: $e');
      }
    }

    // 읽음 처리
    final result = await markMessagesAsRead(roomId);
    result.fold(
      (failure) {
        print('⚠️ 읽음 처리 실패: ${failure.message}');
      },
      (_) {
        // 읽음 처리 성공 시 채팅방 목록의 unreadCount 업데이트
        _updateUnreadCount(roomId, 0);
        print('✅ 읽음 처리 완료 및 unreadCount 업데이트: $roomId');
      },
    );
  }

  /// 타이핑 이벤트 처리
  void _handleTypingEvent(Map<String, dynamic> event) {
    final isTyping = event['isTyping'] as bool? ?? false;
    final userName = event['userName'] as String?;
    
    _isOtherUserTyping = isTyping;
    _typingUserName = userName;
    notifyListeners();
    
    print('📥 타이핑 이벤트 수신: isTyping=$isTyping, userName=$userName');
  }

  /// 채팅방 퇴장 (구독 해제)
  void leaveRoom(String roomId) {
    if (_isConnected && _subscribedRoomId == roomId) {
      webSocketRepository.unsubscribe(roomId);
      webSocketRepository.unsubscribeFromTyping(roomId);
      _subscribedRoomId = null;
    }
    _currentRoom = null;
    _messages = [];
    _currentPage = 0;
    _hasMoreMessages = true;
    _isOtherUserTyping = false;
    _typingUserName = null;
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

  /// 타이핑 이벤트 전송
  void sendTypingEvent({
    required String roomId,
    required bool isTyping,
  }) {
    if (!_isConnected) {
      return;
    }

    try {
      webSocketRepository.sendTypingEvent(
        roomId: roomId,
        isTyping: isTyping,
      );
    } catch (e) {
      print('⚠️ 타이핑 이벤트 전송 실패: $e');
    }
  }

  /// 채팅방의 읽지 않은 메시지 수 업데이트
  void _updateUnreadCount(String roomId, int count) {
    final index = _chatRooms.indexWhere((room) => room.roomId == roomId);
    if (index != -1) {
      final room = _chatRooms[index];
      _chatRooms[index] = ChatRoom(
        id: room.id,
        roomId: room.roomId,
        storeId: room.storeId,
        distributorId: room.distributorId,
        storeName: room.storeName,
        distributorName: room.distributorName,
        isActive: room.isActive,
        lastMessageAt: room.lastMessageAt,
        unreadCount: count,
      );
      notifyListeners();
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 모든 상태 초기화 (로그아웃 시 사용)
  Future<void> reset() async {
    print('=== ChatProvider 상태 초기화 ===');
    
    // WebSocket 연결 해제
    if (_isConnected) {
      await disconnectWebSocket();
    }
    
    // 모든 상태 초기화
    _chatRooms = [];
    _messages = [];
    _currentRoom = null;
    _isLoading = false;
    _error = null;
    _currentPage = 0;
    _hasMoreMessages = true;
    _subscribedRoomId = null;
    _isOtherUserTyping = false;
    _typingUserName = null;
    
    print('ChatProvider 초기화 완료');
    notifyListeners();
  }
}
