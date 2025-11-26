import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/cart_provider.dart';
import 'package:fresh_flow/presentation/pages/order_confirmation_page.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  final String distributorId;
  final String distributorName;

  const CartPage({
    super.key,
    required this.distributorId,
    required this.distributorName,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart(widget.distributorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          '${widget.distributorName} 장바구니',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              if (provider.cart != null && provider.cart!.items.isNotEmpty) {
                return TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('장바구니 비우기'),
                        content: const Text('장바구니를 비우시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                            child: const Text('비우기'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await provider.clearCart(widget.distributorId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('장바구니를 비웠습니다')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    '전체 삭제',
                    style: TextStyle(color: Color(0xFFEF4444)),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.state == CartState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == CartState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage ?? '오류가 발생했습니다'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadCart(widget.distributorId);
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final cart = provider.cart;
          if (cart == null || cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '장바구니가 비어있습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상품 이미지
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: item.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image, size: 40);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.image, size: 40),
                          ),
                          const SizedBox(width: 12),
                          
                          // 상품 정보
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
                                  '${numberFormat.format(item.unitPrice)}원/${item.unit}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // 수량 조절
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 16),
                                            onPressed: item.quantity > 1
                                                ? () {
                                                    provider.updateQuantity(
                                                      widget.distributorId,
                                                      item.id,
                                                      item.quantity - 1,
                                                    );
                                                  }
                                                : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 16),
                                            onPressed: () {
                                              provider.updateQuantity(
                                                widget.distributorId,
                                                item.id,
                                                item.quantity + 1,
                                              );
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${numberFormat.format(item.subtotal)}원',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // 삭제 버튼
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('상품 삭제'),
                                  content: const Text('이 상품을 장바구니에서 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444),
                                      ),
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                await provider.removeItem(
                                  widget.distributorId,
                                  item.id,
                                );
                              }
                            },
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // 하단 주문 요약
              Container(
                padding: const EdgeInsets.all(20),
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 상품 수',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${cart.totalQuantity}개',
                            style: const TextStyle(
                              fontSize: 14,
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
                            '총 금액',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '${numberFormat.format(cart.totalAmount)}원',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderConfirmationPage(
                                  cart: cart,
                                  distributorName: widget.distributorName,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '주문하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
