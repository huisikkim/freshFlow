import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/quality_issue.dart';

abstract class QualityIssueRepository {
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
  });

  Future<Either<Failure, QualityIssue>> getIssue(int issueId);
  Future<Either<Failure, List<QualityIssue>>> getStoreIssues(String storeId);
  Future<Either<Failure, List<QualityIssue>>> getPendingIssues(
      String distributorId);
  Future<Either<Failure, List<QualityIssue>>> getDistributorIssues(
      String distributorId);
  Future<Either<Failure, QualityIssue>> startReview(int issueId);
  Future<Either<Failure, QualityIssue>> approveIssue(
      int issueId, String comment);
  Future<Either<Failure, QualityIssue>> rejectIssue(
      int issueId, String comment);
  Future<Either<Failure, QualityIssue>> schedulePickup(
      int issueId, DateTime pickupTime);
  Future<Either<Failure, QualityIssue>> completePickup(int issueId);
  Future<Either<Failure, QualityIssue>> completeResolution(
      int issueId, String note);
}
