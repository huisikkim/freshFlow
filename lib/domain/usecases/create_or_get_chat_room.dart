import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

/// 채팅방 생성 또는 조회 UseCase
/// Single Responsibility: 채팅방 생성/조회만 담당
class CreateOrGetChatRoom {
  final ChatRepository repository;

  CreateOrGetChatRoom(this.repository);

  Future<Either<Failure, ChatRoom>> call({
    required String storeId,
    required String distributorId,
  }) async {
    return await repository.createOrGetChatRoom(
      storeId: storeId,
      distributorId: distributorId,
    );
  }
}
