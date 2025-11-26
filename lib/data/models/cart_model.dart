import 'package:fresh_flow/domain/entities/cart.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.unitPrice,
    required super.unit,
    required super.quantity,
    required super.subtotal,
    super.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      unitPrice: json['unitPrice'] as int,
      unit: json['unit'] as String,
      quantity: json['quantity'] as int,
      subtotal: json['subtotal'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class CartModel extends Cart {
  const CartModel({
    required super.id,
    required super.storeId,
    required super.distributorId,
    required super.items,
    required super.totalAmount,
    required super.totalQuantity,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>;
    final items = itemsList
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CartModel(
      id: json['id'] as int,
      storeId: json['storeId'] as String,
      distributorId: json['distributorId'] as String,
      items: items,
      totalAmount: json['totalAmount'] as int,
      totalQuantity: json['totalQuantity'] as int,
    );
  }
}
