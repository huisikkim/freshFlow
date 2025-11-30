import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/domain/entities/order.dart';
import 'package:fresh_flow/presentation/providers/delivery_provider.dart';
import 'package:fresh_flow/presentation/providers/order_provider.dart';
import 'package:fresh_flow/presentation/widgets/ship_delivery_modal.dart';
import 'package:fresh_flow/presentation/pages/create_store_review_page.dart';
import 'package:fresh_flow/presentation/pages/create_distributor_review_page.dart';
import 'package:fresh_flow/presentation/pages/quality_issue/submit_quality_issue_page.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          '주문 상세',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8FA),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주문 상태
              _buildStatusCard(isDark),
              const SizedBox(height: 16),

              // 주문 정보
              _buildInfoCard(numberFormat, isDark),
              const SizedBox(height: 16),

              // 주문 상품
              _buildProductsCard(numberFormat, isDark),
              const SizedBox(height: 16),

              // 배송 정보
              _buildDeliveryCard(isDark),
              const SizedBox(height: 16),

              // 유통업자용 배송 관리 버튼
              if (isDistributor && order.status == OrderStatus.confirmed)
                _buildDistributorActions(context, isDark),
              
              // 유통업자용 배송 완료 버튼 (배송중 상태일 때)
              if (isDistributor && order.status == OrderStatus.shipped)
                _buildDeliveryCompleteButton(context, isDark),

              // 리뷰 작성 버튼 (배송완료 상태일 때)
              if (order.status == OrderStatus.delivered)
                _buildReviewButton(context, isDark),
              
              // 품질 이슈 신고 버튼 (배송완료 상태일 때, 가게사장님만)
              if (!isDistributor && order.status == OrderStatus.delivered) ...[
                const SizedBox(height: 16),
                _buildQualityIssueButton(context, isDark),
              ],
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributorActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '배송 관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
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
                backgroundColor: const Color(0xFF14C873),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCompleteButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '배송 관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
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
                backgroundColor: const Color(0xFF14C873),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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

  Widget _buildQualityIssueButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.report_problem_outlined,
                color: isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '품질 문제가 있나요?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '상품에 문제가 있으면 신고해주세요. 환불 또는 교환 처리해드립니다.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitQualityIssuePage(
                      storeId: order.storeId,
                      // 주문 정보를 미리 채워서 전달
                      prefilledData: {
                        'orderId': order.dbId?.toString() ?? order.id,
                        'distributorId': order.distributorId,
                      },
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.report,
                color: isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316),
              ),
              label: Text(
                '품질 이슈 신고하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context, bool isDark) {
    // 서버 응답에서 리뷰 작성 여부 확인
    final hasReviewed = isDistributor
        ? (order.hasDistributorReview ?? false)
        : (order.hasStoreReview ?? false);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '거래 평가',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (hasReviewed) ...[
            // 리뷰 작성 완료 상태
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF6366F1).withOpacity(0.15)
                    : const Color(0xFF6366F1).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '리뷰 등록 완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '소중한 리뷰 감사합니다!',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark 
                                ? const Color(0xFFA5B4FC).withOpacity(0.9)
                                : const Color(0xFF6366F1).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 리뷰 작성 가능 상태
            Text(
              '거래가 완료되었습니다. 상대방을 평가해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                  backgroundColor: const Color(0xFF14C873),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _navigateToReviewPage(BuildContext context) async {
    final orderProvider = context.read<OrderProvider>();
    
    // 리뷰 작성 전 최신 주문 정보 확인
    if (isDistributor) {
      await orderProvider.getDistributorOrders();
    } else {
      await orderProvider.getOrders();
    }

    // 최신 주문 정보에서 리뷰 작성 여부 재확인
    if (context.mounted) {
      final orders = orderProvider.orders;
      
      // 현재 주문의 최신 정보 찾기 (없으면 현재 주문 사용)
      Order? updatedOrder;
      try {
        updatedOrder = orders.firstWhere((o) => o.id == order.id);
      } catch (e) {
        updatedOrder = order;
      }
      
      final hasReviewed = isDistributor
          ? (updatedOrder.hasDistributorReview ?? false)
          : (updatedOrder.hasStoreReview ?? false);

      if (hasReviewed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 리뷰를 작성한 주문입니다'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context); // 상세 페이지 닫기
        return;
      }
    }

    if (!context.mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => isDistributor
            ? CreateDistributorReviewPage(order: order)
            : CreateStoreReviewPage(order: order),
      ),
    );

    // 리뷰 작성 완료 후 주문 목록 새로고침
    if (result == true && context.mounted) {
      if (isDistributor) {
        await orderProvider.getDistributorOrders();
      } else {
        await orderProvider.getOrders();
      }
      
      // 현재 페이지 닫기
      if (context.mounted) {
        Navigator.pop(context);
      }
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

  Widget _buildStatusCard(bool isDark) {
    final statusColor = _getStatusColor(order.status);
    final statusBgColor = statusColor.withOpacity(isDark ? 0.2 : 0.1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: statusColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            order.status.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('yyyy년 MM월 dd일 HH:mm').format(order.createdAt),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(NumberFormat numberFormat, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('주문번호', order.id, isDark),
          const SizedBox(height: 16),
          _buildInfoRow('유통업체', order.distributorName, isDark),
          const SizedBox(height: 16),
          _buildInfoRow('주문일시', DateFormat('yyyy.MM.dd HH:mm').format(order.createdAt), isDark),
        ],
      ),
    );
  }

  Widget _buildProductsCard(NumberFormat numberFormat, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 상품',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          ...order.items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == order.items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${numberFormat.format(item.unitPrice)}원/${item.unit} × ${item.quantity}${item.unit}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${numberFormat.format(item.subtotal)}원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '배송 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('배송 주소', order.deliveryAddress, isDark),
          const SizedBox(height: 16),
          _buildInfoRow('연락처', order.deliveryPhone, isDark),
          if (order.desiredDeliveryDate != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              '희망 배송일',
              DateFormat('yyyy년 MM월 dd일').format(order.desiredDeliveryDate!),
              isDark,
            ),
          ],
          if (order.deliveryRequest != null && order.deliveryRequest!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow('배송 요청사항', order.deliveryRequest!, isDark),
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

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
            ),
            textAlign: TextAlign.right,
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
