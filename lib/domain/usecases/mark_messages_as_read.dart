import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

/// 메시지 읽음 처리 UseCase
/// Single Responsibility: 메시지 읽음 처리만 담당
class MarkMessagesAsRead {
  final ChatRepository repository;

  MarkMessagesAsRead(this.repository);

  Future<Either<Failure, void>> call(String roomId) async {
    return await repository.markAsRead(roomId);
  }
}
