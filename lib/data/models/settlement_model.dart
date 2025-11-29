// 정산 관련 데이터 모델

/// 개별 정산 응답 모델
class SettlementModel {
  final String settlementId;
  final String storeId;
  final String distributorId;
  final String orderId;
  final int settlementAmount;
  final int outstandingAmount;
  final int paidAmount;
  final String status; // PENDING, PROCESSING, COMPLETED, FAILED
  final DateTime settlementDate;
  final DateTime? completedAt;

  SettlementModel({
    required this.settlementId,
    required this.storeId,
    required this.distributorId,
    required this.orderId,
    required this.settlementAmount,
    required this.outstandingAmount,
    required this.paidAmount,
    required this.status,
    required this.settlementDate,
    this.completedAt,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      settlementId: json['settlementId'] as String,
      storeId: json['storeId'] as String,
      distributorId: json['distributorId'] as String,
      orderId: json['orderId'] as String,
      settlementAmount: json['settlementAmount'] as int,
      outstandingAmount: json['outstandingAmount'] as int,
      paidAmount: json['paidAmount'] as int,
      status: json['status'] as String,
      settlementDate: DateTime.parse(json['settlementDate'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settlementId': settlementId,
      'storeId': storeId,
      'distributorId': distributorId,
      'orderId': orderId,
      'settlementAmount': settlementAmount,
      'outstandingAmount': outstandingAmount,
      'paidAmount': paidAmount,
      'status': status,
      'settlementDate': settlementDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// 일일 정산 응답 모델
class DailySettlementModel {
  final int id;
  final DateTime settlementDate;
  final String storeId;
  final String distributorId;
  final int orderCount;
  final int totalSalesAmount;
  final int totalSettlementAmount;
  final int totalPaidAmount;
  final int totalOutstandingAmount;
  final int catalogOrderCount;
  final int catalogSalesAmount;
  final int ingredientOrderCount;
  final int ingredientSalesAmount;
  final double paymentRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailySettlementModel({
    required this.id,
    required this.settlementDate,
    required this.storeId,
    required this.distributorId,
    required this.orderCount,
    required this.totalSalesAmount,
    required this.totalSettlementAmount,
    required this.totalPaidAmount,
    required this.totalOutstandingAmount,
    required this.catalogOrderCount,
    required this.catalogSalesAmount,
    required this.ingredientOrderCount,
    required this.ingredientSalesAmount,
    required this.paymentRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailySettlementModel.fromJson(Map<String, dynamic> json) {
    return DailySettlementModel(
      id: json['id'] as int,
      settlementDate: DateTime.parse(json['settlementDate'] as String),
      storeId: json['storeId'] as String,
      distributorId: json['distributorId'] as String,
      orderCount: json['orderCount'] as int,
      totalSalesAmount: json['totalSalesAmount'] as int,
      totalSettlementAmount: json['totalSettlementAmount'] as int,
      totalPaidAmount: json['totalPaidAmount'] as int,
      totalOutstandingAmount: json['totalOutstandingAmount'] as int,
      catalogOrderCount: json['catalogOrderCount'] as int,
      catalogSalesAmount: json['catalogSalesAmount'] as int,
      ingredientOrderCount: json['ingredientOrderCount'] as int,
      ingredientSalesAmount: json['ingredientSalesAmount'] as int,
      paymentRate: (json['paymentRate'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// 정산 통계 응답 모델
class SettlementStatisticsModel {
  final String type; // STORE or DISTRIBUTOR
  final String id;
  final int totalOrderCount;
  final int totalSalesAmount;
  final int totalPaidAmount;
  final int totalOutstandingAmount;
  final int catalogOrderCount;
  final int catalogSalesAmount;
  final int ingredientOrderCount;
  final int ingredientSalesAmount;
  final double paymentRate;

  SettlementStatisticsModel({
    required this.type,
    required this.id,
    required this.totalOrderCount,
    required this.totalSalesAmount,
    required this.totalPaidAmount,
    required this.totalOutstandingAmount,
    required this.catalogOrderCount,
    required this.catalogSalesAmount,
    required this.ingredientOrderCount,
    required this.ingredientSalesAmount,
    required this.paymentRate,
  });

  factory SettlementStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SettlementStatisticsModel(
      type: json['type'] as String,
      id: json['id'] as String,
      totalOrderCount: json['totalOrderCount'] as int,
      totalSalesAmount: json['totalSalesAmount'] as int,
      totalPaidAmount: json['totalPaidAmount'] as int,
      totalOutstandingAmount: json['totalOutstandingAmount'] as int,
      catalogOrderCount: json['catalogOrderCount'] as int,
      catalogSalesAmount: json['catalogSalesAmount'] as int,
      ingredientOrderCount: json['ingredientOrderCount'] as int,
      ingredientSalesAmount: json['ingredientSalesAmount'] as int,
      paymentRate: (json['paymentRate'] as num).toDouble(),
    );
  }
}

/// 총 미수금 응답 모델
class TotalOutstandingModel {
  final int totalOutstanding;

  TotalOutstandingModel({required this.totalOutstanding});

  factory TotalOutstandingModel.fromJson(Map<String, dynamic> json) {
    return TotalOutstandingModel(
      totalOutstanding: json['totalOutstanding'] as int,
    );
  }
}
