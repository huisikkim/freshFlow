import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/paginated_messages.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/websocket_data_source.dart';

/// 채팅 리포지토리 구현
/// Single Responsibility: 데이터 소스 조율 및 에러 처리
/// Dependency Inversion: 인터페이스에 의존
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final WebSocketDataSource webSocketDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketDataSource,
  });

  @override
  Future<Either<Failure, ChatRoom>> createOrGetChatRoom({
    required String storeId,
    required String distributorId,
  }) async {
    try {
      final result = await remoteDataSource.createOrGetChatRoom(
        storeId: storeId,
        distributorId: distributorId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatRoom>>> getChatRooms() async {
    try {
      final result = await remoteDataSource.getChatRooms();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedMessages>> getMessages({
    required String roomId,
    int page = 0,
    int size = 50,
  }) async {
    try {
      final result = await remoteDataSource.getMessages(
        roomId: roomId,
        page: page,
        size: size,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String roomId) async {
    try {
      final result = await remoteDataSource.getUnreadCount(roomId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String roomId) async {
    try {
      await remoteDataSource.markAsRead(roomId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String roomId,
    required String content,
    required String messageType,
    String? metadata,
  }) async {
    try {
      webSocketDataSource.sendMessage(
        roomId: roomId,
        content: content,
        messageType: messageType,
        metadata: metadata,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
