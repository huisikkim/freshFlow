import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/quality_issue.dart';

class DistributorPendingIssuesPage extends StatefulWidget {
  final String distributorId;

  const DistributorPendingIssuesPage({super.key, required this.distributorId});

  @override
  State<DistributorPendingIssuesPage> createState() =>
      _DistributorPendingIssuesPageState();
}

class _DistributorPendingIssuesPageState
    extends State<DistributorPendingIssuesPage> {
  final List<QualityIssue> _pendingIssues = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingIssues();
  }

  Future<void> _loadPendingIssues() async {
    setState(() => _isLoading = true);
    // TODO: API 호출
    setState(() => _isLoading = false);
  }

  Future<void> _approveIssue(int issueId) async {
    // TODO: 승인 API 호출
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('승인되었습니다.')),
    );
    _loadPendingIssues();
  }

  Future<void> _rejectIssue(int issueId) async {
    // TODO: 거절 API 호출
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('거절되었습니다.')),
    );
    _loadPendingIssues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대기 중인 품질 이슈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingIssues,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingIssues.isEmpty
              ? const Center(child: Text('대기 중인 이슈가 없습니다.'))
              : ListView.builder(
                  itemCount: _pendingIssues.length,
                  itemBuilder: (context, index) {
                    final issue = _pendingIssues[index];
                    return _buildIssueCard(issue);
                  },
                ),
    );
  }

  Widget _buildIssueCard(QualityIssue issue) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.itemName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('가게: ${issue.storeName}'),
            Text('이슈: ${issue.issueTypeDescription}'),
            Text('설명: ${issue.description}'),
            Text(
              '신고일: ${DateFormat('yyyy-MM-dd HH:mm').format(issue.submittedAt)}',
            ),
            const SizedBox(height: 8),
            if (issue.photoUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: issue.photoUrls.length,
                  itemBuilder: (context, photoIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.network(
                        issue.photoUrls[photoIndex],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showRejectDialog(issue.id),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('거절'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showApproveDialog(issue.id),
                  child: const Text('승인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(int issueId) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('품질 이슈 승인'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: '코멘트',
            hintText: '승인 사유를 입력하세요',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveIssue(issueId);
            },
            child: const Text('승인'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(int issueId) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('품질 이슈 거절'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: '코멘트',
            hintText: '거절 사유를 입력하세요',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectIssue(issueId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('거절'),
          ),
        ],
      ),
    );
  }
}
