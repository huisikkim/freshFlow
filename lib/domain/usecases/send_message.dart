import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

/// 메시지 전송 UseCase
/// Single Responsibility: 메시지 전송만 담당
class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, void>> call({
    required String roomId,
    required String content,
    required String messageType,
    String? metadata,
  }) async {
    return await repository.sendMessage(
      roomId: roomId,
      content: content,
      messageType: messageType,
      metadata: metadata,
    );
  }
}
