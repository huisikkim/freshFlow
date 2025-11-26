import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/cart.dart';
import 'package:fresh_flow/domain/usecases/cart_usecases.dart';

enum CartState { initial, loading, success, error }

class CartProvider extends ChangeNotifier {
  final AddToCartUseCase addToCartUseCase;
  final GetCartUseCase getCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final RemoveCartItemUseCase removeCartItemUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartState _state = CartState.initial;
  Cart? _cart;
  String? _errorMessage;

  CartState get state => _state;
  Cart? get cart => _cart;
  String? get errorMessage => _errorMessage;

  CartProvider({
    required this.addToCartUseCase,
    required this.getCartUseCase,
    required this.updateCartItemQuantityUseCase,
    required this.removeCartItemUseCase,
    required this.clearCartUseCase,
  });

  Future<void> addToCart(int productId, int quantity) async {
    _state = CartState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await addToCartUseCase.execute(productId, quantity);
      _state = CartState.success;
      notifyListeners();
    } catch (e) {
      _state = CartState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCart(String distributorId) async {
    _state = CartState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await getCartUseCase.execute(distributorId);
      _state = CartState.success;
      notifyListeners();
    } catch (e) {
      _state = CartState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(
      String distributorId, int itemId, int quantity) async {
    _state = CartState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await updateCartItemQuantityUseCase.execute(
          distributorId, itemId, quantity);
      _state = CartState.success;
      notifyListeners();
    } catch (e) {
      _state = CartState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItem(String distributorId, int itemId) async {
    _state = CartState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await removeCartItemUseCase.execute(distributorId, itemId);
      // 삭제 후 장바구니 다시 로드
      await loadCart(distributorId);
    } catch (e) {
      _state = CartState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart(String distributorId) async {
    _state = CartState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await clearCartUseCase.execute(distributorId);
      _cart = null;
      _state = CartState.success;
      notifyListeners();
    } catch (e) {
      _state = CartState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = CartState.initial;
    _cart = null;
    _errorMessage = null;
    notifyListeners();
  }
}
