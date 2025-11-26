import 'package:fresh_flow/domain/entities/cart.dart';
import 'package:fresh_flow/domain/repositories/cart_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/data/datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  Future<String> _getToken() async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }
    return user.accessToken;
  }

  @override
  Future<Cart> addToCart(int productId, int quantity) async {
    final token = await _getToken();
    return await remoteDataSource.addToCart(token, productId, quantity);
  }

  @override
  Future<Cart> getCart(String distributorId) async {
    final token = await _getToken();
    return await remoteDataSource.getCart(token, distributorId);
  }

  @override
  Future<Cart> updateCartItemQuantity(
      String distributorId, int itemId, int quantity) async {
    final token = await _getToken();
    return await remoteDataSource.updateCartItemQuantity(
        token, distributorId, itemId, quantity);
  }

  @override
  Future<void> removeCartItem(String distributorId, int itemId) async {
    final token = await _getToken();
    await remoteDataSource.removeCartItem(token, distributorId, itemId);
  }

  @override
  Future<void> clearCart(String distributorId) async {
    final token = await _getToken();
    await remoteDataSource.clearCart(token, distributorId);
  }
}
