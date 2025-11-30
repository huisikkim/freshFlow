import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/quality_issue.dart';
import '../repositories/quality_issue_repository.dart';

class SubmitQualityIssue {
  final QualityIssueRepository repository;

  SubmitQualityIssue(this.repository);

  Future<Either<Failure, QualityIssue>> call({
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
    return await repository.submitIssue(
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
  }
}
