class Product {
  final int id;
  final String distributorId;
  final String productName;
  final String category;
  final String description;
  final int unitPrice;
  final String unit;
  final int stockQuantity;
  final String origin;
  final String brand;
  final String? imageUrl;
  final bool isAvailable;
  final int minOrderQuantity;
  final int maxOrderQuantity;
  final String? certifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.distributorId,
    required this.productName,
    required this.category,
    required this.description,
    required this.unitPrice,
    required this.unit,
    required this.stockQuantity,
    required this.origin,
    required this.brand,
    this.imageUrl,
    required this.isAvailable,
    required this.minOrderQuantity,
    required this.maxOrderQuantity,
    this.certifications,
    required this.createdAt,
    required this.updatedAt,
  });
}
