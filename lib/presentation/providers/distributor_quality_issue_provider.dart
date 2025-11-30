import 'package:flutter/material.dart';
import '../../domain/entities/quality_issue.dart';
import '../../domain/usecases/get_pending_quality_issues.dart';
import '../../domain/usecases/approve_quality_issue.dart';
import '../../domain/usecases/reject_quality_issue.dart';

class DistributorQualityIssueProvider with ChangeNotifier {
  final GetPendingQualityIssues getPendingQualityIssues;
  final ApproveQualityIssue approveQualityIssue;
  final RejectQualityIssue rejectQualityIssue;

  DistributorQualityIssueProvider({
    required this.getPendingQualityIssues,
    required this.approveQualityIssue,
    required this.rejectQualityIssue,
  });

  List<QualityIssue> _pendingIssues = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<QualityIssue> get pendingIssues => _pendingIssues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPendingIssues(String distributorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getPendingQualityIssues(distributorId);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
        notifyListeners();
      },
      (issues) {
        _pendingIssues = issues;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> approve(int issueId, String comment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await approveQualityIssue(issueId, comment);

    _isLoading = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.toString();
        notifyListeners();
        return false;
      },
      (issue) {
        _pendingIssues.removeWhere((i) => i.id == issueId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> reject(int issueId, String comment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await rejectQualityIssue(issueId, comment);

    _isLoading = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.toString();
        notifyListeners();
        return false;
      },
      (issue) {
        _pendingIssues.removeWhere((i) => i.id == issueId);
        notifyListeners();
        return true;
      },
    );
  }
}
