import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/order_provider.dart';
import 'package:fresh_flow/presentation/pages/order_detail_page.dart';
import 'package:fresh_flow/presentation/pages/store_delivery_list_page.dart';
import 'package:fresh_flow/domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          '주문 내역',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF9FAFB),
          ),
        ),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFFD4AF37),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StoreDeliveryListPage(),
                ),
              );
            },
            tooltip: '배송 조회',
          ),
        ],
      ),
      body: _buildBody(orderProvider, numberFormat),
    );
  }

  Widget _buildBody(OrderProvider provider, NumberFormat numberFormat) {
    if (provider.state == OrderState.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
        ),
      );
    }

    if (provider.state == OrderState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? '주문 내역을 불러올 수 없습니다',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.getOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1F2937),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (provider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Color(0xFF4B5563),
            ),
            SizedBox(height: 16),
            Text(
              '주문 내역이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.getOrders();
      },
      color: const Color(0xFFD4AF37),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.orders.length,
        itemBuilder: (context, index) {
          final order = provider.orders[index];
          return _buildOrderCard(order, numberFormat);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, NumberFormat numberFormat) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailPage(order: order),
                ),
              );
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.distributorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF9FAFB),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy.MM.dd HH:mm').format(order.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.status.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 상품 요약과 금액
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.items.length == 1
                                ? order.items.first.productName
                                : '${order.items.first.productName} 외 ${order.items.length - 1}건',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD1D5DB),
                            ),
                          ),
                        ),
                        Text(
                          '${numberFormat.format(order.totalAmount)}원',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 배송완료 시 리뷰 CTA
          if (isDelivered && !(order.hasStoreReview ?? false))
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailPage(order: order),
                  ),
                );
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(
                          Icons.rate_review,
                          color: Color(0xFFD4AF37),
                          size: 18,
                        ),
                        SizedBox(width: 12),
                        Text(
                          '리뷰를 남겨주세요',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFFD4AF37),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

          // 주문대기 상태 안내
          if (order.status == OrderStatus.pending)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                '배송이 시작되면 진행 상태를 확인할 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),

          // 취소된 주문 - 다시 주문하기
          if (isCancelled)
            InkWell(
              onTap: () {
                // 다시 주문하기 기능 구현 예정
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다시 주문하기 기능은 준비 중입니다')),
                );
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '다시 주문하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_top;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.inventory_2;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFF59E0B);
      case OrderStatus.confirmed:
        return const Color(0xFF3B82F6);
      case OrderStatus.preparing:
        return const Color(0xFF8B5CF6);
      case OrderStatus.shipped:
        return const Color(0xFF06B6D4);
      case OrderStatus.delivered:
        return const Color(0xFF10B981);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }
}
