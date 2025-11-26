import 'package:fresh_flow/domain/entities/cart.dart';

abstract class CartRepository {
  Future<Cart> addToCart(int productId, int quantity);
  Future<Cart> getCart(String distributorId);
  Future<Cart> updateCartItemQuantity(
      String distributorId, int itemId, int quantity);
  Future<void> removeCartItem(String distributorId, int itemId);
  Future<void> clearCart(String distributorId);
}
