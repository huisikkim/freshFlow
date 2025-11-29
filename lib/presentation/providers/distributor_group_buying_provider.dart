import 'package:flutter/foundation.dart';
import '../../domain/entities/group_buying_room.dart';
import '../../domain/usecases/create_room.dart';
import '../../domain/usecases/get_distributor_rooms.dart';
import '../../domain/usecases/open_room.dart';

class DistributorGroupBuyingProvider with ChangeNotifier {
  final CreateRoom createRoom;
  final GetDistributorRooms getDistributorRooms;
  final OpenRoom openRoom;

  DistributorGroupBuyingProvider({
    required this.createRoom,
    required this.getDistributorRooms,
    required this.openRoom,
  });

  List<GroupBuyingRoom> _myRooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroupBuyingRoom> get myRooms => _myRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createGroupBuyingRoom({
    required String roomTitle,
    required String distributorId,
    required String distributorName,
    required int productId,
    required double discountRate,
    required int availableStock,
    required int targetQuantity,
    required int minOrderPerStore,
    required int minParticipants,
    required String region,
    required double deliveryFee,
    required String deliveryFeeType,
    required int durationHours,
    int? maxOrderPerStore,
    int? maxParticipants,
    String? expectedDeliveryDate,
    String? description,
    String? specialNote,
    bool? featured,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await createRoom(
      roomTitle: roomTitle,
      distributorId: distributorId,
      distributorName: distributorName,
      productId: productId,
      discountRate: discountRate,
      availableStock: availableStock,
      targetQuantity: targetQuantity,
      minOrderPerStore: minOrderPerStore,
      minParticipants: minParticipants,
      region: region,
      deliveryFee: deliveryFee,
      deliveryFeeType: deliveryFeeType,
      durationHours: durationHours,
      maxOrderPerStore: maxOrderPerStore,
      maxParticipants: maxParticipants,
      expectedDeliveryDate: expectedDeliveryDate,
      description: description,
      specialNote: specialNote,
      featured: featured,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (room) {
        success = true;
        _isLoading = false;
        notifyListeners();
      },
    );

    return success;
  }

  Future<void> fetchMyRooms(String distributorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getDistributorRooms(distributorId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (rooms) {
        _myRooms = rooms;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> openGroupBuyingRoom({
    required String roomId,
    required String distributorId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await openRoom(
      roomId: roomId,
      distributorId: distributorId,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        success = true;
        _isLoading = false;
        notifyListeners();
      },
    );

    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
