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
    if (_stompClient?.connected ?? false) {
      return;
    }

    final completer = Completer<void>();

    _stompClient = StompClient(
      config: StompConfig(
        url: '${ApiConstants.wsUrl}/ws/chat',
        onConnect: (StompFrame frame) {
          _connectionStateController.add(true);
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onWebSocketError: (dynamic error) {
          _connectionStateController.add(false);
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        onStompError: (StompFrame frame) {
          _connectionStateController.add(false);
        },
        onDisconnect: (StompFrame frame) {
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
    return completer.future;
  }

  @override
  Future<void> disconnect() async {
    _subscriptions.clear();
    _unsubscribeFunctions.clear();
    _stompClient?.deactivate();
    _stompClient = null;
    _connectionStateController.add(false);
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

    _stompClient!.send(
      destination: '/app/chat/$roomId',
      body: jsonEncode({
        'content': content,
        'messageType': messageType,
        'metadata': metadata,
      }),
    );
  }
}
