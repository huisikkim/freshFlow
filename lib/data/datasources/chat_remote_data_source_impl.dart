import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/chat_room_model.dart';
import '../models/paginated_messages_model.dart';
import 'chat_remote_data_source.dart';

/// 채팅 원격 데이터 소스 구현
/// Single Responsibility: HTTP 통신만 담당
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final Future<String?> Function() getAccessToken;

  ChatRemoteDataSourceImpl({
    required this.client,
    required this.getAccessToken,
  });

  Future<Map<String, String>> get _headers async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  @override
  Future<ChatRoomModel> createOrGetChatRoom({
    required String storeId,
    required String distributorId,
  }) async {
    final headers = await _headers;
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/chat/rooms'),
      headers: headers,
      body: jsonEncode({
        'storeId': storeId,
        'distributorId': distributorId,
      }),
    );

    if (response.statusCode == 200) {
      return ChatRoomModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: 'Failed to create or get chat room');
    }
  }

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    final headers = await _headers;
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/chat/rooms'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ChatRoomModel.fromJson(json)).toList();
    } else {
      throw ServerException(message: 'Failed to get chat rooms');
    }
  }

  @override
  Future<PaginatedMessagesModel> getMessages({
    required String roomId,
    int page = 0,
    int size = 50,
  }) async {
    final headers = await _headers;
    final response = await client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/api/chat/rooms/$roomId/messages?page=$page&size=$size',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return PaginatedMessagesModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: 'Failed to get messages');
    }
  }

  @override
  Future<int> getUnreadCount(String roomId) async {
    final headers = await _headers;
    final response = await client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/api/chat/rooms/$roomId/unread-count',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw ServerException(message: 'Failed to get unread count');
    }
  }

  @override
  Future<void> markAsRead(String roomId) async {
    final headers = await _headers;
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/api/chat/rooms/$roomId/read'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Failed to mark as read');
    }
  }
}
