import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/quality_issue.dart';

class QualityIssueDetailPage extends StatelessWidget {
  final int issueId;

  const QualityIssueDetailPage({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('품질 이슈 상세'),
      ),
      body: Center(
        child: Text('이슈 ID: $issueId\n상세 정보는 추후 구현'),
      ),
    );
  }
}
