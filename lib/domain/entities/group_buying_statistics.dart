import 'package:equatable/equatable.dart';

class DistributorStatistics extends Equatable {
  final String distributorId;
  final int totalRooms;
  final int openRooms;
  final int successRooms;
  final int failedRooms;
  final double successRate;
  final double totalRevenue;
  final int totalParticipants;

  const DistributorStatistics({
    required this.distributorId,
    required this.totalRooms,
    required this.openRooms,
    required this.successRooms,
    required this.failedRooms,
    required this.successRate,
    required this.totalRevenue,
    required this.totalParticipants,
  });

  @override
  List<Object?> get props => [
        distributorId,
        totalRooms,
        openRooms,
        successRooms,
        failedRooms,
        successRate,
        totalRevenue,
        totalParticipants,
      ];
}

class StoreStatistics extends Equatable {
  final String storeId;
  final int totalParticipations;
  final int activeParticipations;
  final int completedOrders;
  final double totalSavings;
  final double totalSpent;

  const StoreStatistics({
    required this.storeId,
    required this.totalParticipations,
    required this.activeParticipations,
    required this.completedOrders,
    required this.totalSavings,
    required this.totalSpent,
  });

  @override
  List<Object?> get props => [
        storeId,
        totalParticipations,
        activeParticipations,
        completedOrders,
        totalSavings,
        totalSpent,
      ];
}

class SystemStatistics extends Equatable {
  final int totalRooms;
  final int openRooms;
  final int successRooms;
  final double successRate;
  final int totalParticipants;
  final double totalRevenue;
  final double totalSavings;

  const SystemStatistics({
    required this.totalRooms,
    required this.openRooms,
    required this.successRooms,
    required this.successRate,
    required this.totalParticipants,
    required this.totalRevenue,
    required this.totalSavings,
  });

  @override
  List<Object?> get props => [
        totalRooms,
        openRooms,
        successRooms,
        successRate,
        totalParticipants,
        totalRevenue,
        totalSavings,
      ];
}
