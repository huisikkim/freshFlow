import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/quality_issue.dart';
import '../../domain/repositories/quality_issue_repository.dart';
import '../datasources/quality_issue_remote_datasource.dart';

class QualityIssueRepositoryImpl implements QualityIssueRepository {
  final QualityIssueRemoteDataSource remoteDataSource;

  QualityIssueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, QualityIssue>> submitIssue({
    required int orderId,
    required int itemId,
    required String itemName,
    required String storeId,
    required String storeName,
    required String distributorId,
    required IssueType issueType,
    required List<String> photoUrls,
    required String description,
    required RequestAction requestAction,
  }) async {
    try {
      final result = await remoteDataSource.submitIssue(
        orderId: orderId,
        itemId: itemId,
        itemName: itemName,
        storeId: storeId,
        storeName: storeName,
        distributorId: distributorId,
        issueType: issueType,
        photoUrls: photoUrls,
        description: description,
        requestAction: requestAction,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QualityIssue>> getIssue(int issueId) async {
    try {
      final result = await remoteDataSource.getIssue(issueId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QualityIssue>>> getStoreIssues(
      String storeId) async {
    try {
      final result = await remoteDataSource.getStoreIssues(storeId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QualityIssue>>> getPendingIssues(
      String distributorId) async {
    try {
      final result = await remoteDataSource.getPendingIssues(distributorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QualityIssue>>> getDistributorIssues(
      String distributorId) async {
    try {
      final result = await remoteDataSource.getDistributorIssues(distributorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QualityIssue>> startReview(int issueId) async {
    try {
      final result = await remoteDataSource.startReview(issueId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QualityIssue>> approveIssue(
      int issueId, String comment) async {
    try {
      final result = await remoteDataSource.approveIssue(issueId, comment);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QualityIssue>> rejectIssue(
      int issueId, String comment) async {
    try {
      final result = await remoteDataSource.rejectIssue(issueId, comment);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QualityIssue>> schedulePickup(
      int issueId, DateTime pickupTime) async {
    try {
      final result = await remoteDataSource.schedulePickup(issueId, pickupTime);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QualityIssue>> completePickup(int issueId) async {
    try {
      final result = await remoteDataSource.completePickup(issueId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QualityIssue>> completeResolution(
      int issueId, String note) async {
    try {
      final result = await remoteDataSource.completeResolution(issueId, note);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
