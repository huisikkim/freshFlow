import 'package:flutter/material.dart';
import 'store_quality_issue_list_page.dart';
import 'distributor_pending_issues_page.dart';

/// 품질 이슈 기능 테스트를 위한 예시 페이지
class QualityIssueExamplePage extends StatelessWidget {
  const QualityIssueExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('품질 이슈 시스템'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '품질 이슈 신고 및 반품/교환 시스템',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const StoreQualityIssueListPage(storeId: 'STORE_001'),
                  ),
                );
              },
              icon: const Icon(Icons.store),
              label: const Text('가게사장님 화면'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DistributorPendingIssuesPage(
                        distributorId: 'DIST_001'),
                  ),
                );
              },
              icon: const Icon(Icons.business),
              label: const Text('유통업자 화면'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '테스트 데이터:\n'
                '가게 ID: STORE_001\n'
                '유통사 ID: DIST_001\n'
                '주문 ID: 123\n'
                '품목 ID: 456',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
