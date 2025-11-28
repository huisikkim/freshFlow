import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/order_provider.dart';
import 'package:fresh_flow/presentation/providers/delivery_provider.dart';
import 'package:fresh_flow/presentation/pages/order_detail_page.dart';
import 'package:fresh_flow/domain/entities/order.dart';
import 'package:intl/intl.dart';

class DistributorOrderListPage extends StatefulWidget {
  const DistributorOrderListPage({super.key});

  @override
  State<DistributorOrderListPage> createState() => _DistributorOrderListPageState();
}

class _DistributorOrderListPageState extends State<DistributorOrderListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().getDistributorOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          '받은 주문',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: _buildBody(orderProvider, numberFormat),
    );
  }

  Widget _buildBody(OrderProvider provider, NumberFormat numberFormat) {
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
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.getDistributorOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
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
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '받은 주문이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.getDistributorOrders();
      },
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
    final statusBgColor = statusColor.withOpacity(0.1);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailPage(
              order: order,
              isDistributor: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy.MM.dd HH:mm').format(order.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.storefront,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                order.storeId,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32, color: Color(0xFFE5E7EB)),

              // 상품 목록
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        Text(
                          '${item.quantity}${item.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '외 ${order.items.length - 2}개',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),

              const Divider(height: 32, color: Color(0xFFE5E7EB)),

              // 배송 정보
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.deliveryPhone,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32, color: Color(0xFFE5E7EB)),

              // 하단 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '총 주문 금액',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    '${numberFormat.format(order.totalAmount)}원',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),

              // 주문확정 상태일 때 배송 시작 버튼 표시
              if (order.status == OrderStatus.confirmed) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailPage(
                            order: order,
                            isDistributor: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_shipping, size: 18),
                    label: const Text(
                      '배송 시작하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],

              // 배송중 상태일 때 배송 완료 버튼 표시
              if (order.status == OrderStatus.shipped) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _completeDelivery(context, order),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text(
                      '배송 완료',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeDelivery(BuildContext context, Order order) async {
    // dbId가 없으면 에러 표시
    if (order.dbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주문 ID를 찾을 수 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('배송 완료'),
        content: const Text('배송을 완료 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('완료'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final deliveryProvider = context.read<DeliveryProvider>();
    final completed =
        await deliveryProvider.completeDelivery(order.dbId.toString());

    if (context.mounted) {
      if (completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('배송이 완료되었습니다'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
        // 주문 목록 새로고침
        context.read<OrderProvider>().getDistributorOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deliveryProvider.errorMessage ?? '배송 완료 처리 실패'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

