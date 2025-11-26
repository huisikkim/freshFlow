import 'package:fresh_flow/domain/entities/cart.dart';
import 'package:fresh_flow/domain/repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;
  AddToCartUseCase(this.repository);

  Future<Cart> execute(int productId, int quantity) async {
    return await repository.addToCart(productId, quantity);
  }
}

class GetCartUseCase {
  final CartRepository repository;
  GetCartUseCase(this.repository);

  Future<Cart> execute(String distributorId) async {
    return await repository.getCart(distributorId);
  }
}

class UpdateCartItemQuantityUseCase {
  final CartRepository repository;
  UpdateCartItemQuantityUseCase(this.repository);

  Future<Cart> execute(
      String distributorId, int itemId, int quantity) async {
    return await repository.updateCartItemQuantity(
        distributorId, itemId, quantity);
  }
}

class RemoveCartItemUseCase {
  final CartRepository repository;
  RemoveCartItemUseCase(this.repository);

  Future<void> execute(String distributorId, int itemId) async {
    await repository.removeCartItem(distributorId, itemId);
  }
}

class ClearCartUseCase {
  final CartRepository repository;
  ClearCartUseCase(this.repository);

  Future<void> execute(String distributorId) async {
    await repository.clearCart(distributorId);
  }
}
