import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/quality_issue.dart';
import '../repositories/quality_issue_repository.dart';

class ApproveQualityIssue {
  final QualityIssueRepository repository;

  ApproveQualityIssue(this.repository);

  Future<Either<Failure, QualityIssue>> call(int issueId, String comment) async {
    return await repository.approveIssue(issueId, comment);
  }
}
