import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/core/constants/api_constants.dart';

class DebugConnectionPage extends StatefulWidget {
  const DebugConnectionPage({super.key});

  @override
  State<DebugConnectionPage> createState() => _DebugConnectionPageState();
}

class _DebugConnectionPageState extends State<DebugConnectionPage> {
  String _result = '연결 테스트를 시작하려면 버튼을 누르세요';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = '테스트 중...';
    });

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/login');
      print('테스트 URL: $url');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: '{"username":"test","password":"test"}',
          )
          .timeout(const Duration(seconds: 5));

      setState(() {
        _result = '''
✅ 연결 성공!

URL: $url
상태 코드: ${response.statusCode}
응답: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '''
❌ 연결 실패

URL: ${ApiConstants.baseUrl}
에러: $e

확인사항:
1. 백엔드 서버가 실행 중인가요?
2. 포트가 8080인가요?
3. Android 에뮬레이터에서는 10.0.2.2 사용
4. iOS 시뮬레이터에서는 localhost 사용
''';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연결 테스트'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '현재 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Base URL: ${ApiConstants.baseUrl}'),
                  Text('개발 모드: ${ApiConstants.isDevelopment}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConnection,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: const Text('연결 테스트'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F61),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
