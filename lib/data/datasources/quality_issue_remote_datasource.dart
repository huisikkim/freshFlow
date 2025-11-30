import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quality_issue_model.dart';
import '../../domain/entities/quality_issue.dart';

abstract class QualityIssueRemoteDataSource {
  Future<QualityIssueModel> submitIssue({
    required int orderId,
    required int itemId,
    required String itemName,
    required String storeId,
    required String storeName,
    required String distributorId,
    required IssueType issueType,
    required List<String> photoUrls,
    required String description,
    required RequestAction requestAction,
  });

  Future<QualityIssueModel> getIssue(int issueId);
  Future<List<QualityIssueModel>> getStoreIssues(String storeId);
  Future<List<QualityIssueModel>> getPendingIssues(String distributorId);
  Future<List<QualityIssueModel>> getDistributorIssues(String distributorId);
  Future<QualityIssueModel> startReview(int issueId);
  Future<QualityIssueModel> approveIssue(int issueId, String comment);
  Future<QualityIssueModel> rejectIssue(int issueId, String comment);
  Future<QualityIssueModel> schedulePickup(int issueId, DateTime pickupTime);
  Future<QualityIssueModel> completePickup(int issueId);
  Future<QualityIssueModel> completeResolution(int issueId, String note);
}

class QualityIssueRemoteDataSourceImpl implements QualityIssueRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  String? _token;

  QualityIssueRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://localhost:8080',
  });

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  @override
  Future<QualityIssueModel> submitIssue({
    required int orderId,
    required int itemId,
    required String itemName,
    required String storeId,
    required String storeName,
    required String distributorId,
    required IssueType issueType,
    required List<String> photoUrls,
    required String description,
    required RequestAction requestAction,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/quality-issues'),
      headers: _headers,
      body: jsonEncode({
        'orderId': orderId,
        'itemId': itemId,
        'itemName': itemName,
        'storeId': storeId,
        'storeName': storeName,
        'distributorId': distributorId,
        'issueType': issueType.name,
        'photoUrls': photoUrls,
        'description': description,
        'requestAction': requestAction.name,
      }),
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('품질 이슈 신고 실패: ${response.body}');
    }
  }

  @override
  Future<QualityIssueModel> getIssue(int issueId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/quality-issues/$issueId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('품질 이슈 조회 실패: ${response.body}');
    }
  }

  @override
  Future<List<QualityIssueModel>> getStoreIssues(String storeId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/quality-issues/store/$storeId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => QualityIssueModel.fromJson(json)).toList();
    } else {
      throw Exception('품질 이슈 목록 조회 실패: ${response.body}');
    }
  }

  @override
  Future<List<QualityIssueModel>> getPendingIssues(String distributorId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/quality-issues/distributor/$distributorId/pending'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => QualityIssueModel.fromJson(json)).toList();
    } else {
      throw Exception('대기 중인 이슈 조회 실패: ${response.body}');
    }
  }

  @override
  Future<List<QualityIssueModel>> getDistributorIssues(
      String distributorId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/quality-issues/distributor/$distributorId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => QualityIssueModel.fromJson(json)).toList();
    } else {
      throw Exception('품질 이슈 목록 조회 실패: ${response.body}');
    }
  }

  @override
  Future<QualityIssueModel> startReview(int issueId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/quality-issues/$issueId/review'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('검토 시작 실패: ${response.body}');
    }
  }

  @override
  Future<QualityIssueModel> approveIssue(int issueId, String comment) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/quality-issues/$issueId/approve'),
      headers: _headers,
      body: jsonEncode({'comment': comment}),
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('승인 실패: ${response.body}');
    }
  }

  @override
  Future<QualityIssueModel> rejectIssue(int issueId, String comment) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/quality-issues/$issueId/reject'),
      headers: _headers,
      body: jsonEncode({'comment': comment}),
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('거절 실패: ${response.body}');
    }
  }

  @override
  Future<QualityIssueModel> schedulePickup(
      int issueId, DateTime pickupTime) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/quality-issues/$issueId/schedule-pickup'),
      headers: _headers,
      body: jsonEncode({
        'pickupTime': pickupTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('수거 예약 실패: ${response.body}');
    }
  }

  @override
  Future<QualityIssueModel> completePickup(int issueId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/quality-issues/$issueId/complete-pickup'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('수거 완료 실패: ${response.body}');
    }
  }

  @override
  Future<QualityIssueModel> completeResolution(int issueId, String note) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/quality-issues/$issueId/complete-resolution'),
      headers: _headers,
      body: jsonEncode({'note': note}),
    );

    if (response.statusCode == 200) {
      return QualityIssueModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('환불/교환 완료 실패: ${response.body}');
    }
  }
}
