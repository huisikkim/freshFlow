import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group_buying_room_model.dart';
import '../models/group_buying_participant_model.dart';
import '../models/group_buying_statistics_model.dart';

abstract class GroupBuyingRemoteDataSource {
  Future<GroupBuyingRoomModel> createRoom(Map<String, dynamic> roomData);
  Future<Map<String, dynamic>> openRoom(String roomId, String distributorId);
  Future<Map<String, dynamic>> closeRoom(String roomId, String distributorId);
  Future<void> cancelRoom(String roomId, String distributorId, String reason);
  Future<List<GroupBuyingRoomModel>> getDistributorRooms(String distributorId);
  Future<List<GroupBuyingRoomModel>> getOpenRooms({String? region, String? category});
  Future<GroupBuyingRoomModel> getRoomDetail(String roomId);
  Future<List<GroupBuyingRoomModel>> getFeaturedRooms();
  Future<List<GroupBuyingRoomModel>> getDeadlineSoonRooms();
  Future<GroupBuyingParticipantModel> joinRoom(Map<String, dynamic> participantData);
  Future<void> cancelParticipation(int participantId, String storeId, String reason);
  Future<List<GroupBuyingParticipantModel>> getStoreParticipations(String storeId);
  Future<List<GroupBuyingParticipantModel>> getRoomParticipants(String roomId);
  Future<DistributorStatisticsModel> getDistributorStatistics(String distributorId);
  Future<StoreStatisticsModel> getStoreStatistics(String storeId);
  Future<SystemStatisticsModel> getSystemStatistics();
}

class GroupBuyingRemoteDataSourceImpl implements GroupBuyingRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  GroupBuyingRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://localhost:8080/api/group-buying',
  });

  @override
  Future<GroupBuyingRoomModel> createRoom(Map<String, dynamic> roomData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(roomData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GroupBuyingRoomModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create room: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> openRoom(String roomId, String distributorId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/rooms/$roomId/open?distributorId=$distributorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to open room: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> closeRoom(String roomId, String distributorId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/rooms/$roomId/close?distributorId=$distributorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to close room: ${response.body}');
    }
  }

  @override
  Future<void> cancelRoom(String roomId, String distributorId, String reason) async {
    final response = await client.post(
      Uri.parse('$baseUrl/rooms/$roomId/cancel?distributorId=$distributorId&reason=${Uri.encodeComponent(reason)}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel room: ${response.body}');
    }
  }

  @override
  Future<List<GroupBuyingRoomModel>> getDistributorRooms(String distributorId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/rooms/distributor/$distributorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GroupBuyingRoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get distributor rooms: ${response.body}');
    }
  }

  @override
  Future<List<GroupBuyingRoomModel>> getOpenRooms({String? region, String? category}) async {
    var uri = Uri.parse('$baseUrl/rooms/open');
    final queryParams = <String, String>{};
    if (region != null) queryParams['region'] = region;
    if (category != null) queryParams['category'] = category;
    
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GroupBuyingRoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get open rooms: ${response.body}');
    }
  }

  @override
  Future<GroupBuyingRoomModel> getRoomDetail(String roomId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return GroupBuyingRoomModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get room detail: ${response.body}');
    }
  }

  @override
  Future<List<GroupBuyingRoomModel>> getFeaturedRooms() async {
    final response = await client.get(
      Uri.parse('$baseUrl/rooms/featured'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GroupBuyingRoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get featured rooms: ${response.body}');
    }
  }

  @override
  Future<List<GroupBuyingRoomModel>> getDeadlineSoonRooms() async {
    final response = await client.get(
      Uri.parse('$baseUrl/rooms/deadline-soon'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GroupBuyingRoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get deadline soon rooms: ${response.body}');
    }
  }

  @override
  Future<GroupBuyingParticipantModel> joinRoom(Map<String, dynamic> participantData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/participants/join'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(participantData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GroupBuyingParticipantModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to join room: ${response.body}');
    }
  }

  @override
  Future<void> cancelParticipation(int participantId, String storeId, String reason) async {
    final response = await client.post(
      Uri.parse('$baseUrl/participants/$participantId/cancel?storeId=$storeId&reason=${Uri.encodeComponent(reason)}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel participation: ${response.body}');
    }
  }

  @override
  Future<List<GroupBuyingParticipantModel>> getStoreParticipations(String storeId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/participants/store/$storeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GroupBuyingParticipantModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get store participations: ${response.body}');
    }
  }

  @override
  Future<List<GroupBuyingParticipantModel>> getRoomParticipants(String roomId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/participants/room/$roomId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GroupBuyingParticipantModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get room participants: ${response.body}');
    }
  }

  @override
  Future<DistributorStatisticsModel> getDistributorStatistics(String distributorId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/statistics/distributor/$distributorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return DistributorStatisticsModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get distributor statistics: ${response.body}');
    }
  }

  @override
  Future<StoreStatisticsModel> getStoreStatistics(String storeId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/statistics/store/$storeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return StoreStatisticsModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get store statistics: ${response.body}');
    }
  }

  @override
  Future<SystemStatisticsModel> getSystemStatistics() async {
    final response = await client.get(
      Uri.parse('$baseUrl/statistics/system'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return SystemStatisticsModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get system statistics: ${response.body}');
    }
  }
}
