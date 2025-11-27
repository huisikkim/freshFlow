import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

/// 채팅방 목록 조회 UseCase
/// Single Responsibility: 채팅방 목록 조회만 담당
class GetChatRooms {
  final ChatRepository repository;

  GetChatRooms(this.repository);

  Future<Either<Failure, List<ChatRoom>>> call() async {
    return await repository.getChatRooms();
  }
}
