import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/domain/entities/cart.dart';
import 'package:fresh_flow/presentation/providers/order_provider.dart';
import 'package:fresh_flow/presentation/providers/cart_provider.dart';
import 'package:fresh_flow/presentation/pages/toss_payment_page.dart';
import 'package:intl/intl.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Cart cart;
  final String distributorId;
  final String distributorName;

  const OrderConfirmationPage({
    super.key,
    required this.cart,
    required this.distributorId,
    required this.distributorName,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final _formKey = GlobalKey<FormState>();
  String _deliveryAddress = '';
  String _deliveryPhone = '';
  String _deliveryRequest = '';
  DateTime _desiredDeliveryDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          '주문 확인',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 유통업체 정보
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Color(0xFF10B981),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '유통업체',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              widget.distributorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 주문 상품 목록
                const Text(
                  '주문 상품',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = widget.cart.items[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${numberFormat.format(item.unitPrice)}원/${item.unit} × ${item.quantity}${item.unit}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${numberFormat.format(item.subtotal)}원',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 배송 정보
                const Text(
                  '배송 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '배송 주소',
                          hintText: '배송받을 주소를 입력하세요',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '배송 주소를 입력하세요';
                          }
                          return null;
                        },
                        onSaved: (value) => _deliveryAddress = value!,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '연락처',
                          hintText: '010-1234-5678',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '연락처를 입력하세요';
                          }
                          return null;
                        },
                        onSaved: (value) => _deliveryPhone = value!,
                      ),
                      const SizedBox(height: 16),
                      
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _desiredDeliveryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() => _desiredDeliveryDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '희망 배송일',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('yyyy년 MM월 dd일').format(_desiredDeliveryDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '배송 요청사항 (선택)',
                          hintText: '배송 시 요청사항을 입력하세요',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                        onSaved: (value) => _deliveryRequest = value ?? '',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 결제 금액
                const Text(
                  '결제 금액',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '상품 금액',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${numberFormat.format(widget.cart.totalAmount)}원',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '배송비',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${numberFormat.format(0)}원',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 결제 금액',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '${numberFormat.format(widget.cart.totalAmount)}원',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // 하단 버튼 공간
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '${numberFormat.format(widget.cart.totalAmount)}원 주문하기',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 주문 확인 다이얼로그
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('주문 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('주문을 진행하시겠습니까?'),
              const SizedBox(height: 16),
              Text(
                '배송 주소: $_deliveryAddress',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              Text(
                '연락처: $_deliveryPhone',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              Text(
                '희망 배송일: ${DateFormat('yyyy-MM-dd').format(_desiredDeliveryDate)}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              if (_deliveryRequest.isNotEmpty)
                Text(
                  '요청사항: $_deliveryRequest',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                _processOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('주문하기'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _processOrder() async {
    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();

    // 장바구니 확인
    if (widget.cart.items.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('주문 불가'),
          content: const Text('장바구니가 비어있습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    print('🛒 장바구니 상태:');
    print('  - 아이템 수: ${widget.cart.items.length}');
    print('  - 총 금액: ${widget.cart.totalAmount}');
    print('  - DistributorId: ${widget.cart.distributorId}');

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 1단계: 주문 생성 API 호출
    final items = widget.cart.items.map((item) => {
      'productId': item.productId,
      'quantity': item.quantity,
    }).toList();

    print('📦 주문 아이템 전송: $items');

    final orderSuccess = await orderProvider.createOrder(
      distributorId: widget.cart.distributorId,
      deliveryAddress: _deliveryAddress,
      deliveryPhone: _deliveryPhone,
      deliveryRequest: _deliveryRequest.isNotEmpty ? _deliveryRequest : null,
      desiredDeliveryDate: _desiredDeliveryDate,
      items: items,
    );

    if (!mounted) return;

    // 로딩 다이얼로그 닫기
    Navigator.pop(context);

    if (!orderSuccess) {
      // 주문 생성 실패
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('주문 실패'),
          content: Text(
            orderProvider.errorMessage ?? '주문 처리 중 오류가 발생했습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // 2단계: 주문 생성 성공 - 결제 진행
    final createdOrder = orderProvider.currentOrder;
    if (createdOrder == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('오류'),
          content: const Text('주문 정보를 가져올 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    print('✅ 주문 생성 완료 - orderId: ${createdOrder.id}');

    // 3단계: 토스페이 결제 페이지로 이동
    final paymentResult = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => TossPaymentPage(
          orderId: 'ORDER-${createdOrder.id}', // 토스페이먼츠 형식: 6자 이상
          orderName: _generateOrderName(),
          amount: widget.cart.totalAmount,
          customerEmail: _deliveryPhone, // 이메일 대신 전화번호 사용
          customerName: '가게사장님', // 실제 사용자 이름으로 변경 가능
        ),
      ),
    );

    if (!mounted) return;

    // 4단계: 결제 결과 처리
    if (paymentResult == null) {
      // 사용자가 뒤로가기로 취소
      print('⚠️ 결제 취소됨');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('결제 취소'),
          content: const Text('결제가 취소되었습니다.\n주문은 생성되었으나 결제가 완료되지 않았습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    if (paymentResult['success'] == true) {
      // 결제 성공 - 승인 API 호출
      print('💳 결제 성공 - 승인 진행');
      
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // paymentResult['orderId']는 'ORDER-6' 형식이므로 숫자만 추출
      final orderIdFromPayment = paymentResult['orderId'].toString().replaceFirst('ORDER-', '');
      
      final confirmSuccess = await orderProvider.confirmPayment(
        orderId: orderIdFromPayment, // 백엔드는 숫자 ID를 기대
        paymentKey: paymentResult['paymentKey'],
        amount: paymentResult['amount'],
      );

      if (!mounted) return;

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      if (confirmSuccess) {
        // 결제 승인 성공 - 장바구니 비우기
        await cartProvider.clearCart(widget.distributorId);

        if (!mounted) return;

        // 성공 다이얼로그 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF10B981),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '결제 및 주문이 완료되었습니다!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '유통업체에서 주문을 확인 중입니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 홈으로 돌아가기
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        );
      } else {
        // 결제 승인 실패
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('결제 승인 실패'),
            content: Text(
              orderProvider.errorMessage ?? '결제 승인 중 오류가 발생했습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } else {
      // 결제 실패
      print('❌ 결제 실패: ${paymentResult['message']}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('결제 실패'),
          content: Text(paymentResult['message'] ?? '결제에 실패했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  String _generateOrderName() {
    if (widget.cart.items.isEmpty) return '주문';
    
    final firstItem = widget.cart.items.first;
    if (widget.cart.items.length == 1) {
      return firstItem.productName;
    } else {
      return '${firstItem.productName} 외 ${widget.cart.items.length - 1}건';
    }
  }
}
