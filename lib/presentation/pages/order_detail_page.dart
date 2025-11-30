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

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          '주문 상세',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE5E7EB),
          ),
        ),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFFE5E7EB),
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

              // 유통업자용 배송 관리 버튼
              if (isDistributor && order.status == OrderStatus.confirmed)
                _buildDistributorActions(context),
              
              // 유통업자용 배송 완료 버튼 (배송중 상태일 때)
              if (isDistributor && order.status == OrderStatus.shipped)
                _buildDeliveryCompleteButton(context),

              // 리뷰 작성 버튼 (배송완료 상태일 때)
              if (order.status == OrderStatus.delivered)
                _buildReviewButton(context),
              
              // 품질 이슈 신고 버튼 (배송완료 상태일 때, 가게사장님만)
              if (!isDistributor && order.status == OrderStatus.delivered) ...[
                const SizedBox(height: 16),
                _buildQualityIssueButton(context),
              ],
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributorActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '배송 관리',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showShipDeliveryModal(context),
              icon: const Icon(Icons.local_shipping, color: Colors.black),
              label: const Text(
                '배송 시작',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '배송 관리',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _completeDelivery(context),
              icon: const Icon(Icons.check_circle, color: Colors.black),
              label: const Text(
                '배송 완료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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

  Widget _buildQualityIssueButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.report_problem_outlined,
                color: Color(0xFFFB923C),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                '품질 문제가 있나요?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '상품에 문제가 있으면 신고해주세요. 환불 또는 교환 처리해드립니다.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
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
              icon: const Icon(
                Icons.report,
                color: Color(0xFFFB923C),
              ),
              label: const Text(
                '품질 이슈 신고하기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFB923C),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(
                  color: Color(0xFFFB923C),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context) {
    // 서버 응답에서 리뷰 작성 여부 확인
    final hasReviewed = isDistributor
        ? (order.hasDistributorReview ?? false)
        : (order.hasStoreReview ?? false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '거래 평가',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 12),
          if (hasReviewed) ...[
            // 리뷰 작성 완료 상태
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF818CF8),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '리뷰 등록 완료',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '소중한 리뷰 감사합니다!',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFFA5B4FC).withOpacity(0.9),
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
            const Text(
              '거래가 완료되었습니다. 상대방을 평가해주세요.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToReviewPage(context),
                icon: const Icon(Icons.star, color: Colors.black),
                label: const Text(
                  '리뷰 작성하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(order.status);
    final statusBgColor = statusColor.withOpacity(0.15);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: statusColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            order.status.displayName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('yyyy년 MM월 dd일 HH:mm').format(order.createdAt),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(NumberFormat numberFormat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주문 정보',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E7EB),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주문 상품',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == order.items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD1D5DB),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${numberFormat.format(item.unitPrice)}원/${item.unit} × ${item.quantity}${item.unit}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${numberFormat.format(item.subtotal)}원',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
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

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF374151).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '배송 정보',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E7EB),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE5E7EB),
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
