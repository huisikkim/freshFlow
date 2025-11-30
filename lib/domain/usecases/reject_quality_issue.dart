import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/quality_issue.dart';
import '../repositories/quality_issue_repository.dart';

class RejectQualityIssue {
  final QualityIssueRepository repository;

  RejectQualityIssue(this.repository);

  Future<Either<Failure, QualityIssue>> call(int issueId, String comment) async {
    return await repository.rejectIssue(issueId, comment);
  }
}
