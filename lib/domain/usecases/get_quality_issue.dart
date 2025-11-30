import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/quality_issue.dart';
import '../repositories/quality_issue_repository.dart';

class GetQualityIssue {
  final QualityIssueRepository repository;

  GetQualityIssue(this.repository);

  Future<Either<Failure, QualityIssue>> call(int issueId) async {
    return await repository.getIssue(issueId);
  }
}
