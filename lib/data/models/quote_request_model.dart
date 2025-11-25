import 'package:fresh_flow/domain/entities/quote_request.dart';

class QuoteRequestModel extends QuoteRequest {
  const QuoteRequestModel({
    required super.id,
    required super.storeId,
    required super.storeName,
    required super.distributorId,
    required super.distributorName,
    required super.requestedProducts,
    super.message,
    required super.status,
    super.estimatedAmount,
    super.distributorResponse,
    required super.requestedAt,
    super.respondedAt,
  });

  factory QuoteRequestModel.fromJson(Map<String, dynamic> json) {
    return QuoteRequestModel(
      id: json['id'] as int,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      distributorId: json['distributorId'] as String,
      distributorName: json['distributorName'] as String,
      requestedProducts: json['requestedProducts'] as String,
      message: json['message'] as String?,
      status: json['status'] as String,
      estimatedAmount: json['estimatedAmount'] as int?,
      distributorResponse: json['distributorResponse'] as String?,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'distributorId': distributorId,
      'requestedProducts': requestedProducts,
      if (message != null) 'message': message,
    };
  }

  Map<String, dynamic> toRespondJson({
    required String status,
    int? estimatedAmount,
    required String response,
  }) {
    return {
      'status': status,
      if (estimatedAmount != null) 'estimatedAmount': estimatedAmount,
      'response': response,
    };
  }
}
