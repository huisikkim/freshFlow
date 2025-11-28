import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/domain/entities/order.dart';
import 'package:fresh_flow/presentation/providers/delivery_provider.dart';
import 'package:fresh_flow/presentation/providers/order_provider.dart';
import 'package:fresh_flow/presentation/widgets/ship_delivery_modal.dart';
import 'package:fresh_flow/presentation/pages/create_store_review_page.dart';
import 'package:fresh_flow/presentation/pages/create_distributor_review_page.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  final bool isDistributor;

  const OrderDetailPage({
    super.key,
    required this.order,
    this.isDistributor = false,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          '주문 상세',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주문 상태
              _buildStatusCard(),
              const SizedBox(height: 16),

              // 주문 정보
              _buildInfoCard(numberFormat),
              const SizedBox(height: 16),

              // 주문 상품
              _buildProductsCard(numberFormat),
              const SizedBox(height: 16),

              // 배송 정보
              _buildDeliveryCard(),
              const SizedBox(height: 16),

              // 결제 정보
              _buildPaymentCard(numberFormat),
              
              // 유통업자용 배송 관리 버튼
              if (isDistributor && order.status == OrderStatus.confirmed)
                _buildDistributorActions(context),
              
              // 유통업자용 배송 완료 버튼 (배송중 상태일 때)
              if (isDistributor && order.status == OrderStatus.shipped)
                _buildDeliveryCompleteButton(context),

              // 리뷰 작성 버튼 (배송완료 상태일 때)
              if (order.status == OrderStatus.delivered)
                _buildReviewButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributorActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '배송 관리',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showShipDeliveryModal(context),
              icon: const Icon(Icons.local_shipping, color: Colors.white),
              label: const Text(
                '배송 시작',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCompleteButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '배송 관리',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _completeDelivery(context),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                '배송 완료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeDelivery(BuildContext context) async {
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
        Navigator.pop(context);
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

  Widget _buildReviewButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '거래 평가',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '거래가 완료되었습니다. 상대방을 평가해주세요.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToReviewPage(context),
              icon: const Icon(Icons.star, color: Colors.white),
              label: const Text(
                '리뷰 작성하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToReviewPage(BuildContext context) {
    if (isDistributor) {
      // 유통업자 -> 가게사장님 평가
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateDistributorReviewPage(order: order),
        ),
      );
    } else {
      // 가게사장님 -> 유통업자 평가
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateStoreReviewPage(order: order),
        ),
      );
    }
  }

  void _showShipDeliveryModal(BuildContext context) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShipDeliveryModal(
        orderId: order.id,
        onShip: ({
          required String deliveryType,
          String? trackingNumber,
          String? courierCompany,
          String? driverName,
          String? driverPhone,
          String? vehicleNumber,
          required DateTime estimatedDate,
        }) async {
          final deliveryProvider = context.read<DeliveryProvider>();

          // 1. 배송 정보 생성 (dbId 사용)
          final created =
              await deliveryProvider.createDelivery(order.dbId.toString());
          if (!created) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(deliveryProvider.errorMessage ?? '배송 정보 생성 실패'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          // 2. 배송 시작 (택배 또는 직접) - dbId 사용
          bool shipped = false;
          if (deliveryType == 'COURIER') {
            shipped = await deliveryProvider.shipDeliveryCourier(
              orderId: order.dbId.toString(),
              trackingNumber: trackingNumber!,
              courierCompany: courierCompany!,
              estimatedDeliveryDate: estimatedDate,
            );
          } else {
            shipped = await deliveryProvider.shipDeliveryDirect(
              orderId: order.dbId.toString(),
              driverName: driverName!,
              driverPhone: driverPhone!,
              vehicleNumber: vehicleNumber!,
              estimatedDeliveryDate: estimatedDate,
            );
          }

          if (context.mounted) {
            if (shipped) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('배송이 시작되었습니다'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
              // 주문 목록 새로고침
              context.read<OrderProvider>().getDistributorOrders();
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(deliveryProvider.errorMessage ?? '배송 시작 실패'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(order.status);
    final statusBgColor = statusColor.withOpacity(0.1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            order.status.displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('yyyy년 MM월 dd일 HH:mm').format(order.createdAt),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(NumberFormat numberFormat) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주문 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('주문번호', order.id),
          const SizedBox(height: 12),
          _buildInfoRow('유통업체', order.distributorName),
          const SizedBox(height: 12),
          _buildInfoRow('주문일시', DateFormat('yyyy.MM.dd HH:mm').format(order.createdAt)),
        ],
      ),
    );
  }

  Widget _buildProductsCard(NumberFormat numberFormat) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주문 상품',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '배송 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('배송 주소', order.deliveryAddress),
          const SizedBox(height: 12),
          _buildInfoRow('연락처', order.deliveryPhone),
          if (order.desiredDeliveryDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              '희망 배송일',
              DateFormat('yyyy년 MM월 dd일').format(order.desiredDeliveryDate!),
            ),
          ],
          if (order.deliveryRequest != null && order.deliveryRequest!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('배송 요청사항', order.deliveryRequest!),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(NumberFormat numberFormat) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결제 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '상품 금액',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '${numberFormat.format(order.totalAmount)}원',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
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
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '${numberFormat.format(0)}원',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                '${numberFormat.format(order.totalAmount)}원',
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.inventory_2_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
