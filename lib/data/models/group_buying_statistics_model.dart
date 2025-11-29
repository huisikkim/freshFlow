import '../../domain/entities/group_buying_statistics.dart';

class DistributorStatisticsModel extends DistributorStatistics {
  const DistributorStatisticsModel({
    required super.distributorId,
    required super.totalRooms,
    required super.openRooms,
    required super.successRooms,
    required super.failedRooms,
    required super.successRate,
    required super.totalRevenue,
    required super.totalParticipants,
  });

  factory DistributorStatisticsModel.fromJson(Map<String, dynamic> json) {
    return DistributorStatisticsModel(
      distributorId: json['distributorId'] as String,
      totalRooms: json['totalRooms'] as int,
      openRooms: json['openRooms'] as int,
      successRooms: json['successRooms'] as int,
      failedRooms: json['failedRooms'] as int,
      successRate: (json['successRate'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalParticipants: json['totalParticipants'] as int,
    );
  }
}

class StoreStatisticsModel extends StoreStatistics {
  const StoreStatisticsModel({
    required super.storeId,
    required super.totalParticipations,
    required super.activeParticipations,
    required super.completedOrders,
    required super.totalSavings,
    required super.totalSpent,
  });

  factory StoreStatisticsModel.fromJson(Map<String, dynamic> json) {
    return StoreStatisticsModel(
      storeId: json['storeId'] as String,
      totalParticipations: json['totalParticipations'] as int,
      activeParticipations: json['activeParticipations'] as int,
      completedOrders: json['completedOrders'] as int,
      totalSavings: (json['totalSavings'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
    );
  }
}

class SystemStatisticsModel extends SystemStatistics {
  const SystemStatisticsModel({
    required super.totalRooms,
    required super.openRooms,
    required super.successRooms,
    required super.successRate,
    required super.totalParticipants,
    required super.totalRevenue,
    required super.totalSavings,
  });

  factory SystemStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SystemStatisticsModel(
      totalRooms: json['totalRooms'] as int,
      openRooms: json['openRooms'] as int,
      successRooms: json['successRooms'] as int,
      successRate: (json['successRate'] as num).toDouble(),
      totalParticipants: json['totalParticipants'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalSavings: (json['totalSavings'] as num).toDouble(),
    );
  }
}
