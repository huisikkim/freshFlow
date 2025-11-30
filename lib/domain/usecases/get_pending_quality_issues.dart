import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/quality_issue.dart';
import '../repositories/quality_issue_repository.dart';

class GetPendingQualityIssues {
  final QualityIssueRepository repository;

  GetPendingQualityIssues(this.repository);

  Future<Either<Failure, List<QualityIssue>>> call(String distributorId) async {
    return await repository.getPendingIssues(distributorId);
  }
}
