class CartItem {
  final int id;
  final int productId;
  final String productName;
  final int unitPrice;
  final String unit;
  final int quantity;
  final int subtotal;
  final String? imageUrl;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unit,
    required this.quantity,
    required this.subtotal,
    this.imageUrl,
  });
}

class Cart {
  final int id;
  final String storeId;
  final String distributorId;
  final List<CartItem> items;
  final int totalAmount;
  final int totalQuantity;

  const Cart({
    required this.id,
    required this.storeId,
    required this.distributorId,
    required this.items,
    required this.totalAmount,
    required this.totalQuantity,
  });
}
