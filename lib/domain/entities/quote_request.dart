class QuoteRequest {
  final int id;
  final String storeId;
  final String storeName;
  final String distributorId;
  final String distributorName;
  final String requestedProducts;
  final String? message;
  final String status; // PENDING, ACCEPTED, REJECTED, COMPLETED
  final int? estimatedAmount;
  final String? distributorResponse;
  final DateTime requestedAt;
  final DateTime? respondedAt;

  const QuoteRequest({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.distributorId,
    required this.distributorName,
    required this.requestedProducts,
    this.message,
    required this.status,
    this.estimatedAmount,
    this.distributorResponse,
    required this.requestedAt,
    this.respondedAt,
  });
}
