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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          '주문 내역',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
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
      body: _buildBody(orderProvider, numberFormat, isDark),
    );
  }

  Widget _buildBody(OrderProvider provider, NumberFormat numberFormat, bool isDark) {
    if (provider.state == OrderState.loading) {
      return const Center(child: CircularProgressIndicator());
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
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.getOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              '주문 내역이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF475569),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.orders.length,
        itemBuilder: (context, index) {
          final order = provider.orders[index];
          return _buildOrderCard(order, numberFormat, isDark);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, NumberFormat numberFormat, bool isDark) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy.MM.dd at HH:mm').format(order.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.status.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 상품 요약과 금액
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFF334155).withOpacity(0.5) 
                          : const Color(0xFFF8FAFC),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        Text(
                          '${numberFormat.format(order.totalAmount)}원',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.rate_review,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '리뷰를 남겨주세요',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981).withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

          // 주문대기 상태 안내
          if (order.status == OrderStatus.pending)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF0F172A).withOpacity(0.5) 
                    : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Text(
                '배송이 시작되면 진행 상태를 확인할 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF0F172A).withOpacity(0.5) 
                      : const Color(0xFFF1F5F9),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    '다시 주문하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
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
