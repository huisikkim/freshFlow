import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/quality_issue.dart';
import '../../providers/quality_issue_provider.dart';
import 'submit_quality_issue_page.dart';
import 'quality_issue_detail_page.dart';

class StoreQualityIssueListPage extends StatefulWidget {
  final String storeId;

  const StoreQualityIssueListPage({super.key, required this.storeId});

  @override
  State<StoreQualityIssueListPage> createState() =>
      _StoreQualityIssueListPageState();
}

class _StoreQualityIssueListPageState extends State<StoreQualityIssueListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIssues();
    });
  }

  Future<void> _loadIssues() async {
    await context.read<QualityIssueProvider>().loadStoreIssues(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('품질 이슈 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIssues,
          ),
        ],
      ),
      body: Consumer<QualityIssueProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadIssues,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (provider.issues.isEmpty) {
            return const Center(
              child: Text('품질 이슈가 없습니다.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadIssues,
            child: ListView.builder(
              itemCount: provider.issues.length,
              itemBuilder: (context, index) {
                final issue = provider.issues[index];
                return _buildIssueCard(issue);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SubmitQualityIssuePage(storeId: widget.storeId),
            ),
          ).then((_) => _loadIssues());
        },
        icon: const Icon(Icons.add),
        label: const Text('품질 이슈 신고'),
      ),
    );
  }

  Widget _buildIssueCard(QualityIssue issue) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildStatusIcon(issue.status),
        title: Text(
          issue.itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(issue.issueTypeDescription),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(issue.submittedAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: _buildStatusChip(issue.status, issue.statusDescription),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QualityIssueDetailPage(issueId: issue.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(IssueStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case IssueStatus.SUBMITTED:
        icon = Icons.assignment;
        color = Colors.orange;
        break;
      case IssueStatus.REVIEWING:
        icon = Icons.search;
        color = Colors.blue;
        break;
      case IssueStatus.APPROVED:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case IssueStatus.REJECTED:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case IssueStatus.PICKUP_SCHEDULED:
        icon = Icons.schedule;
        color = Colors.purple;
        break;
      case IssueStatus.PICKED_UP:
        icon = Icons.local_shipping;
        color = Colors.teal;
        break;
      case IssueStatus.REFUNDED:
      case IssueStatus.EXCHANGED:
        icon = Icons.done_all;
        color = Colors.indigo;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(IssueStatus status, String description) {
    Color color;

    switch (status) {
      case IssueStatus.SUBMITTED:
        color = Colors.orange;
        break;
      case IssueStatus.REVIEWING:
        color = Colors.blue;
        break;
      case IssueStatus.APPROVED:
        color = Colors.green;
        break;
      case IssueStatus.REJECTED:
        color = Colors.red;
        break;
      case IssueStatus.PICKUP_SCHEDULED:
        color = Colors.purple;
        break;
      case IssueStatus.PICKED_UP:
        color = Colors.teal;
        break;
      case IssueStatus.REFUNDED:
      case IssueStatus.EXCHANGED:
        color = Colors.indigo;
        break;
    }

    return Chip(
      label: Text(
        description,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
