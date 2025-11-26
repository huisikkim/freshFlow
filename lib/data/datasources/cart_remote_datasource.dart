import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/cart_model.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> addToCart(String token, int productId, int quantity);
  Future<CartModel> getCart(String token, String distributorId);
  Future<CartModel> updateCartItemQuantity(
      String token, String distributorId, int itemId, int quantity);
  Future<void> removeCartItem(
      String token, String distributorId, int itemId);
  Future<void> clearCart(String token, String distributorId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;

  CartRemoteDataSourceImpl(this.client);

  @override
  Future<CartModel> addToCart(
      String token, int productId, int quantity) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        return CartModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('장바구니 추가 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<CartModel> getCart(String token, String distributorId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/cart/$distributorId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return CartModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('장바구니 조회 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<CartModel> updateCartItemQuantity(
      String token, String distributorId, int itemId, int quantity) async {
    try {
      final response = await client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/cart/$distributorId/items/$itemId?quantity=$quantity'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return CartModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('수량 변경 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<void> removeCartItem(
      String token, String distributorId, int itemId) async {
    try {
      final response = await client.delete(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/cart/$distributorId/items/$itemId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('아이템 삭제 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCart(String token, String distributorId) async {
    try {
      final response = await client.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/cart/$distributorId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('장바구니 비우기 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }
}
