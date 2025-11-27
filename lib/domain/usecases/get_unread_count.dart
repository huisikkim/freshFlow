import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

/// 읽지 않은 메시지 수 조회 UseCase
/// Single Responsibility: 읽지 않은 메시지 수 조회만 담당
class GetUnreadCount {
  final ChatRepository repository;

  GetUnreadCount(this.repository);

  Future<Either<Failure, int>> call(String roomId) async {
    return await repository.getUnreadCount(roomId);
  }
}
