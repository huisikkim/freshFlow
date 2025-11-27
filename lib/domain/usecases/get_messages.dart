import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/paginated_messages.dart';
import '../repositories/chat_repository.dart';

/// 메시지 목록 조회 UseCase
/// Single Responsibility: 메시지 목록 조회만 담당
class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Future<Either<Failure, PaginatedMessages>> call({
    required String roomId,
    int page = 0,
    int size = 50,
  }) async {
    return await repository.getMessages(
      roomId: roomId,
      page: page,
      size: size,
    );
  }
}
