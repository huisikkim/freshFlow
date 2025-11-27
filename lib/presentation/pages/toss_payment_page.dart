import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class TossPaymentPage extends StatefulWidget {
  final String orderId;
  final String orderName;
  final int amount;
  final String customerEmail;
  final String customerName;

  const TossPaymentPage({
    super.key,
    required this.orderId,
    required this.orderName,
    required this.amount,
    required this.customerEmail,
    required this.customerName,
  });

  @override
  State<TossPaymentPage> createState() => _TossPaymentPageState();
}

class _TossPaymentPageState extends State<TossPaymentPage> with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isWaitingForPaymentResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 앱 생명주기 변경: $state');
    
    if (state == AppLifecycleState.resumed && _isWaitingForPaymentResult) {
      print('✅ 앱이 포그라운드로 돌아옴 - 결제 결과 확인 중...');
      // 외부 앱에서 돌아온 후 현재 URL 확인
      _controller.currentUrl().then((url) {
        if (url != null) {
          print('📍 현재 URL: $url');
          _checkPaymentResult(url);
        }
      });
    } else if (state == AppLifecycleState.paused) {
      print('⏸️ 앱이 백그라운드로 이동');
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('📨 JavaScript 메시지: ${message.message}');
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🌐 페이지 로딩 시작: $url');
            _checkPaymentResult(url);
          },
          onPageFinished: (String url) {
            print('✅ 페이지 로딩 완료: $url');
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView 에러: ${error.description}');
            // ERR_UNKNOWN_URL_SCHEME 에러는 무시 (앱 딥링크)
            if (error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
              print('ℹ️ 외부 앱 URL 감지됨 (정상)');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            print('🔗 네비게이션 요청: $url');
            
            // 외부 앱 URL 처리 (카카오페이, 네이버페이 등)
            if (_isExternalAppUrl(url)) {
              print('📱 외부 앱 URL 감지: $url');
              _launchExternalApp(url);
              return NavigationDecision.prevent;
            }
            
            _checkPaymentResult(url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.dataFromString(
          _generatePaymentHtml(),
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );
  }

  bool _isExternalAppUrl(String url) {
    return url.startsWith('intent://') ||
        url.startsWith('kakaotalk://') ||
        url.startsWith('kakaopay://') ||
        url.startsWith('supertoss://') ||
        url.startsWith('hdcardappcardansimclick://') ||
        url.startsWith('shinhan-sr-ansimclick://') ||
        url.startsWith('kb-acp://') ||
        url.startsWith('mpocket.online.ansimclick://') ||
        url.startsWith('lottesmartpay://') ||
        url.startsWith('lotteappcard://') ||
        url.startsWith('cloudpay://') ||
        url.startsWith('nhappcardansimclick://') ||
        url.startsWith('citispay://') ||
        url.startsWith('payco://') ||
        url.startsWith('lguthepay://') ||
        url.startsWith('samsungpay://');
  }

  Future<void> _launchExternalApp(String url) async {
    try {
      // 외부 앱으로 이동하므로 결제 결과 대기 상태로 설정
      setState(() {
        _isWaitingForPaymentResult = true;
      });
      
      print('🔗 원본 URL: $url');
      
      String? appUrl;
      
      // intent:// URL 파싱
      if (url.startsWith('intent://')) {
        // scheme 추출 (예: kakaotalk)
        final schemeMatch = RegExp(r'scheme=([^;]+)').firstMatch(url);
        final scheme = schemeMatch?.group(1);
        
        // intent:// 이후 #Intent 이전까지가 경로
        final intentData = url.replaceFirst('intent://', '');
        final intentEnd = intentData.indexOf('#Intent');
        
        if (intentEnd > 0 && scheme != null) {
          final path = intentData.substring(0, intentEnd);
          appUrl = '$scheme://$path';
          print('📱 변환된 앱 URL: $appUrl');
        } else {
          print('❌ intent URL 파싱 실패');
        }
      } else {
        // 일반 앱 스킴 URL
        appUrl = url;
        print('📱 직접 앱 URL: $appUrl');
      }
      
      // 앱 URL 실행
      if (appUrl != null) {
        try {
          final uri = Uri.parse(appUrl);
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          if (launched) {
            print('✅ 앱 실행 성공 - 결제 진행 중...');
            return;
          } else {
            print('⚠️ launchUrl 반환값 false');
          }
        } catch (e) {
          print('⚠️ 앱 URL 실행 실패: $e');
        }
      }
      
      // 실패 시 fallback URL 시도
      if (url.contains('browser_fallback_url')) {
        final fallbackMatch = RegExp(r'S\.browser_fallback_url=([^;]+)').firstMatch(url);
        if (fallbackMatch != null) {
          final fallbackUrl = Uri.decodeComponent(fallbackMatch.group(1)!);
          print('🔄 Fallback URL로 재시도: $fallbackUrl');
          
          try {
            final fallbackUri = Uri.parse(fallbackUrl);
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
            print('✅ Fallback URL 실행 성공');
            return;
          } catch (e) {
            print('❌ Fallback URL 실행 실패: $e');
          }
        }
      }
      
      // 모든 시도 실패
      print('❌ 모든 앱 실행 시도 실패');
      setState(() {
        _isWaitingForPaymentResult = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결제 앱을 실행할 수 없습니다. 카카오톡이 설치되어 있는지 확인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('⚠️ 외부 앱 실행 중 예외 발생: $e');
      setState(() {
        _isWaitingForPaymentResult = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('앱 실행 중 오류: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleJavaScriptMessage(String message) {
    try {
      final data = json.decode(message);
      final type = data['type'];

      if (type == 'LOG') {
        print('🌐 [WebView] ${data['message']}');
      } else if (type == 'ERROR') {
        print('❌ [WebView] ${data['message']}');
        Navigator.of(context).pop({
          'success': false,
          'code': 'JS_ERROR',
          'message': data['message'],
        });
      } else if (type == 'PAYMENT_REDIRECT') {
        print('🔄 [WebView] 결제 페이지로 리다이렉트 중...');
      }
    } catch (e) {
      print('⚠️ JavaScript 메시지 파싱 실패: $message');
    }
  }

  String _generatePaymentHtml() {
    // 토스페이먼츠 클라이언트 키
    const clientKey = ApiConstants.tossPaymentsClientKey;
    
    // 성공/실패 URL (앱에서 감지할 URL)
    final successUrl = 'https://freshflow-app.com/payment/success';
    final failUrl = 'https://freshflow-app.com/payment/fail';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>토스페이먼츠 결제</title>
  <script src="https://js.tosspayments.com/v1/payment"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      padding: 20px;
      background: #f8f9fa;
    }
    .container {
      max-width: 500px;
      margin: 0 auto;
      background: white;
      border-radius: 12px;
      padding: 24px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    h2 {
      font-size: 20px;
      margin-bottom: 20px;
      color: #333;
    }
    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 12px 0;
      border-bottom: 1px solid #eee;
    }
    .info-label {
      color: #666;
      font-size: 14px;
    }
    .info-value {
      color: #333;
      font-size: 14px;
      font-weight: 600;
    }
    .amount {
      font-size: 24px;
      color: #3182F6;
      font-weight: bold;
    }
    #payment-button {
      width: 100%;
      padding: 16px;
      background-color: #3182F6;
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: bold;
      cursor: pointer;
      margin-top: 24px;
    }
    #payment-button:active {
      background-color: #2563EB;
    }
    .loading {
      text-align: center;
      padding: 40px 20px;
      color: #666;
    }
  </style>
</head>
<body>
  <div class="container">
    <h2>결제 정보</h2>
    <div class="info-row">
      <span class="info-label">주문명</span>
      <span class="info-value">${widget.orderName}</span>
    </div>
    <div class="info-row">
      <span class="info-label">주문번호</span>
      <span class="info-value">${widget.orderId}</span>
    </div>
    <div class="info-row" style="border-bottom: none; padding-top: 20px;">
      <span class="info-label">결제금액</span>
      <span class="amount">${widget.amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원</span>
    </div>
    
    <button id="payment-button">결제하기</button>
  </div>

  <script>
    // Flutter와 통신하기 위한 헬퍼 함수
    function sendToFlutter(type, message) {
      if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify({ type: type, message: message }));
      }
      console.log('[' + type + ']', message);
    }

    sendToFlutter('LOG', '🚀 결제 페이지 로드');
    
    const clientKey = '$clientKey';
    const orderId = '${widget.orderId}';
    const orderName = '${widget.orderName}';
    const amount = ${widget.amount};
    const customerName = '${widget.customerName}';
    
    sendToFlutter('LOG', '📋 결제 정보: orderId=' + orderId + ', amount=' + amount);
    
    let tossPayments;
    
    try {
      tossPayments = TossPayments(clientKey);
      sendToFlutter('LOG', '✅ TossPayments 초기화 완료');
    } catch (error) {
      sendToFlutter('ERROR', 'TossPayments 초기화 실패: ' + error.message);
      alert('결제 시스템 초기화에 실패했습니다: ' + error.message);
    }

    document.getElementById('payment-button').addEventListener('click', async function() {
      sendToFlutter('LOG', '💳 결제 버튼 클릭');
      
      if (!tossPayments) {
        alert('결제 시스템이 준비되지 않았습니다.');
        return;
      }
      
      this.disabled = true;
      this.textContent = '결제 진행 중...';
      
      try {
        sendToFlutter('LOG', '🔄 결제 요청 시작');
        sendToFlutter('PAYMENT_REDIRECT', '결제 페이지로 이동');
        
        // 카드 및 간편결제 모두 허용
        await tossPayments.requestPayment('카드', {
          amount: amount,
          orderId: orderId,
          orderName: orderName,
          customerName: customerName,
          successUrl: '$successUrl',
          failUrl: '$failUrl',
          cardCompany: null, // 모든 카드사 허용
          useEscrow: false,
          flowMode: 'DEFAULT',
          easyPay: null, // 모든 간편결제 허용
        });
        
        sendToFlutter('LOG', '✅ 결제 요청 완료 (리다이렉트됨)');
      } catch (error) {
        sendToFlutter('ERROR', '결제 요청 실패: ' + error.message);
        alert('결제 요청 중 오류가 발생했습니다: ' + (error.message || '알 수 없는 오류'));
        this.disabled = false;
        this.textContent = '결제하기';
      }
    });
    
    sendToFlutter('LOG', '✅ 페이지 준비 완료');
  </script>
</body>
</html>
    ''';
  }

  void _checkPaymentResult(String url) {
    // data: URL은 무시 (HTML 로드 시)
    if (url.startsWith('data:')) {
      return;
    }
    
    print('🔍 URL 체크: $url');
    
    if (url.startsWith('https://freshflow-app.com/payment/success')) {
      // 결제 성공
      setState(() {
        _isWaitingForPaymentResult = false;
      });
      
      final uri = Uri.parse(url);
      final paymentKey = uri.queryParameters['paymentKey'];
      final orderId = uri.queryParameters['orderId'];
      final amount = uri.queryParameters['amount'];

      print('✅ 결제 성공!');
      print('  - paymentKey: $paymentKey');
      print('  - orderId: $orderId');
      print('  - amount: $amount');

      if (paymentKey != null && orderId != null && amount != null) {
        Navigator.of(context).pop({
          'success': true,
          'paymentKey': paymentKey,
          'orderId': orderId,
          'amount': int.parse(amount),
        });
      } else {
        print('⚠️ 결제 성공했으나 파라미터가 누락됨');
        Navigator.of(context).pop({
          'success': false,
          'code': 'MISSING_PARAMS',
          'message': '결제 정보를 받지 못했습니다',
        });
      }
    } else if (url.startsWith('https://freshflow-app.com/payment/fail')) {
      // 결제 실패
      setState(() {
        _isWaitingForPaymentResult = false;
      });
      
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      final message = uri.queryParameters['message'];

      print('❌ 결제 실패!');
      print('  - code: $code');
      print('  - message: $message');

      Navigator.of(context).pop({
        'success': false,
        'code': code,
        'message': message ?? '결제에 실패했습니다',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '토스페이먼츠 결제',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('결제 페이지 로딩 중...'),
                  ],
                ),
              ),
            ),
          if (_isWaitingForPaymentResult)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      '결제 진행 중...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '결제 완료 후 자동으로 돌아옵니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
