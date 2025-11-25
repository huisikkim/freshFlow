import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/core/constants/api_constants.dart';
import 'package:fresh_flow/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<String> signUp(String username, String password, String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String username, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
    
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserModel.fromJson(jsonData);
    } else {
      throw Exception('로그인 실패: ${response.statusCode}');
    }
  }

  @override
  Future<String> signUp(String username, String password, String email) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.signUpEndpoint}');
    
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('회원가입 실패: ${response.statusCode}');
    }
  }
}
