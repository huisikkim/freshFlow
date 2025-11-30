import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/quality_issue.dart';
import '../repositories/quality_issue_repository.dart';

class GetStoreQualityIssues {
  final QualityIssueRepository repository;

  GetStoreQualityIssues(this.repository);

  Future<Either<Failure, List<QualityIssue>>> call(String storeId) async {
    return await repository.getStoreIssues(storeId);
  }
}
