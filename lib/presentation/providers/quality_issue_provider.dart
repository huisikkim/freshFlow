import 'package:flutter/material.dart';
import '../../domain/entities/quality_issue.dart';
import '../../domain/usecases/submit_quality_issue.dart';
import '../../domain/usecases/get_store_quality_issues.dart';

class QualityIssueProvider with ChangeNotifier {
  final SubmitQualityIssue submitQualityIssue;
  final GetStoreQualityIssues getStoreQualityIssues;

  QualityIssueProvider({
    required this.submitQualityIssue,
    required this.getStoreQualityIssues,
  });

  List<QualityIssue> _issues = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<QualityIssue> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStoreIssues(String storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getStoreQualityIssues(storeId);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
        notifyListeners();
      },
      (issues) {
        _issues = issues;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> submitIssue({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await submitQualityIssue(
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

    _isLoading = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.toString();
        notifyListeners();
        return false;
      },
      (issue) {
        _issues.insert(0, issue);
        notifyListeners();
        return true;
      },
    );
  }
}
