import 'package:flutter/foundation.dart';
import '../../domain/entities/group_buying_room.dart';
import '../../domain/entities/group_buying_participant.dart';
import '../../domain/usecases/get_open_rooms.dart';
import '../../domain/usecases/get_room_detail.dart';
import '../../domain/usecases/join_room.dart';
import '../../domain/usecases/get_store_participations.dart';

class GroupBuyingProvider with ChangeNotifier {
  final GetOpenRooms getOpenRooms;
  final GetRoomDetail getRoomDetail;
  final JoinRoom joinRoom;
  final GetStoreParticipations getStoreParticipations;

  GroupBuyingProvider({
    required this.getOpenRooms,
    required this.getRoomDetail,
    required this.joinRoom,
    required this.getStoreParticipations,
  });

  List<GroupBuyingRoom> _openRooms = [];
  GroupBuyingRoom? _selectedRoom;
  List<GroupBuyingParticipant> _myParticipations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroupBuyingRoom> get openRooms => _openRooms;
  GroupBuyingRoom? get selectedRoom => _selectedRoom;
  List<GroupBuyingParticipant> get myParticipations => _myParticipations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOpenRooms({String? region, String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getOpenRooms(region: region, category: category);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (rooms) {
        _openRooms = rooms;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchRoomDetail(String roomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getRoomDetail(roomId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (room) {
        _selectedRoom = room;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> joinGroupBuying({
    required String roomId,
    required String storeId,
    required int quantity,
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryRequest,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await joinRoom(
      roomId: roomId,
      storeId: storeId,
      quantity: quantity,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryRequest: deliveryRequest,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (participant) {
        success = true;
        _isLoading = false;
        notifyListeners();
      },
    );

    return success;
  }

  Future<void> fetchMyParticipations(String storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getStoreParticipations(storeId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (participations) {
        _myParticipations = participations;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
