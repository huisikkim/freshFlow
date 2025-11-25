import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/core/constants/api_constants.dart';
import 'package:fresh_flow/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<String> signUp({
    required String username,
    required String password,
    required String email,
    required String userType,
    required String businessNumber,
    required String businessName,
    required String ownerName,
    required String phoneNumber,
    required String address,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      print('🔵 로그인 요청 URL: $url');
      
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('🔵 로그인 응답 상태: ${response.statusCode}');
      print('🔵 로그인 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UserModel.fromJson(jsonData);
      } else {
        throw Exception('로그인 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('🔴 로그인 에러: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('서버에 연결할 수 없습니다.\n\n확인사항:\n1. 백엔드 서버가 실행 중인지 확인\n2. URL: ${ApiConstants.baseUrl}\n3. Android 에뮬레이터는 10.0.2.2 사용\n4. iOS 시뮬레이터는 localhost 사용');
      }
      rethrow;
    }
  }

  @override
  Future<String> signUp({
    required String username,
    required String password,
    required String email,
    required String userType,
    required String businessNumber,
    required String businessName,
    required String ownerName,
    required String phoneNumber,
    required String address,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.signUpEndpoint}');
    
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'userType': userType,
        'businessNumber': businessNumber,
        'businessName': businessName,
        'ownerName': ownerName,
        'phoneNumber': phoneNumber,
        'address': address,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('회원가입 실패: ${response.statusCode}');
    }
  }
}
