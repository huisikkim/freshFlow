import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';
import 'websocket_data_source.dart';

/// WebSocket 데이터 소스 구현
/// Single Responsibility: WebSocket 통신만 담당
class WebSocketDataSourceImpl implements WebSocketDataSource {
  StompClient? _stompClient;
  final Map<String, Function(ChatMessage)> _subscriptions = {};
  final Map<String, StompUnsubscribe> _unsubscribeFunctions = {};
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  @override
  bool get isConnected => _stompClient?.connected ?? false;

  @override
  Future<void> connect(String accessToken) async {
    // 기존 연결이 있으면 먼저 끊기 (다른 사용자로 로그인한 경우 대비)
    if (_stompClient?.connected ?? false) {
      print('⚠️ 기존 WebSocket 연결 해제 후 재연결');
      await disconnect();
    }

    print('=== WebSocket 연결 시도 ===');
    print('accessToken: ${accessToken.substring(0, 20)}...');
    print('URL: ${ApiConstants.baseUrl}/ws/chat');
    print('==========================\n');

    final completer = Completer<void>();

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${ApiConstants.baseUrl}/ws/chat',
        onConnect: (StompFrame frame) {
          print('✅ WebSocket 연결 성공');
          _connectionStateController.add(true);
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onWebSocketError: (dynamic error) {
          print('❌ WebSocket 에러: $error');
          _connectionStateController.add(false);
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        onStompError: (StompFrame frame) {
          print('❌ STOMP 에러: ${frame.body}');
          _connectionStateController.add(false);
        },
        onDisconnect: (StompFrame frame) {
          print('🔌 WebSocket 연결 해제');
          _connectionStateController.add(false);
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $accessToken',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    _stompClient!.activate();
    
    // 10초 타임아웃 설정
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('❌ WebSocket 연결 타임아웃');
        throw Exception('WebSocket 연결 타임아웃 (10초)');
      },
    );
  }

  @override
  Future<void> disconnect() async {
    print('=== WebSocket 연결 해제 시작 ===');
    
    // 모든 구독 해제
    for (var roomId in _unsubscribeFunctions.keys.toList()) {
      try {
        _unsubscribeFunctions[roomId]?.call();
      } catch (e) {
        print('구독 해제 실패 ($roomId): $e');
      }
    }
    
    _subscriptions.clear();
    _unsubscribeFunctions.clear();
    
    // STOMP 클라이언트 비활성화
    if (_stompClient != null) {
      try {
        _stompClient!.deactivate();
      } catch (e) {
        print('STOMP 비활성화 실패: $e');
      }
      _stompClient = null;
    }
    
    _connectionStateController.add(false);
    print('=== WebSocket 연결 해제 완료 ===\n');
  }

  @override
  void subscribe(String roomId, Function(ChatMessage) onMessage) {
    if (!isConnected) {
      throw Exception('WebSocket is not connected');
    }

    _subscriptions[roomId] = onMessage;

    final unsubscribe = _stompClient!.subscribe(
      destination: '/topic/chat/$roomId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final json = jsonDecode(frame.body!);
          final message = ChatMessageModel.fromJson(json);
          final callback = _subscriptions[roomId];
          if (callback != null) {
            callback(message);
          }
        }
      },
    );

    _unsubscribeFunctions[roomId] = unsubscribe;
  }

  @override
  void unsubscribe(String roomId) {
    _subscriptions.remove(roomId);
    final unsubscribe = _unsubscribeFunctions.remove(roomId);
    if (unsubscribe != null) {
      unsubscribe();
    }
  }

  @override
  void sendMessage({
    required String roomId,
    required String content,
    required String messageType,
    String? metadata,
  }) {
    if (!isConnected) {
      throw Exception('WebSocket is not connected');
    }

    final messageBody = {
      'content': content,
      'messageType': messageType,
      'metadata': metadata,
    };

    print('=== WebSocket 메시지 전송 ===');
    print('roomId: $roomId');
    print('content: $content');
    print('messageType: $messageType');
    print('messageBody: ${jsonEncode(messageBody)}');
    print('WebSocket 연결 상태: ${_stompClient?.connected}');
    print('============================\n');

    _stompClient!.send(
      destination: '/app/chat/$roomId',
      body: jsonEncode(messageBody),
    );
  }
}
