import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/delivery_provider.dart';
import 'package:fresh_flow/domain/entities/delivery.dart';
import 'package:intl/intl.dart';

class StoreDeliveryListPage extends StatefulWidget {
  const StoreDeliveryListPage({super.key});

  @override
  State<StoreDeliveryListPage> createState() => _StoreDeliveryListPageState();
}

class _StoreDeliveryListPageState extends State<StoreDeliveryListPage> {
  DeliveryStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().getStoreDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          '배송 조회',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _buildBody(deliveryProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('전체', null),
          const SizedBox(width: 8),
          _buildFilterChip('상품준비중', DeliveryStatus.preparing),
          const SizedBox(width: 8),
          _buildFilterChip('배송중', DeliveryStatus.shipped),
          const SizedBox(width: 8),
          _buildFilterChip('배송완료', DeliveryStatus.delivered),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DeliveryStatus? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF10B981).withOpacity(0.1),
      checkmarkColor: const Color(0xFF10B981),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
      ),
    );
  }

  Widget _buildBody(DeliveryProvider provider) {
    if (provider.state == DeliveryState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == DeliveryState.error) {
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
              provider.errorMessage ?? '배송 정보를 불러올 수 없습니다',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.getStoreDeliveries(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final filteredDeliveries = _selectedStatus == null
        ? provider.deliveries
        : provider.deliveries.where((d) => d.status == _selectedStatus).toList();

    if (filteredDeliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '배송 내역이 없습니다',
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
        await provider.getStoreDeliveries();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = filteredDeliveries[index];
          return _buildDeliveryCard(delivery);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    final statusColor = _getStatusColor(delivery.status);
    final statusBgColor = statusColor.withOpacity(0.1);

    return Container(
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
              children: [
                Text(
                  DateFormat('yyyy.MM.dd HH:mm').format(delivery.createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
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
                    delivery.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24, color: Color(0xFFE5E7EB)),

            // 배송 정보
            if (delivery.deliveryType != null) ...[
              _buildInfoRow(
                Icons.local_shipping_outlined,
                '배송 방식',
                delivery.deliveryType!.displayName,
              ),
              const SizedBox(height: 12),
            ],
            
            // 택배 배송 정보
            if (delivery.deliveryType == DeliveryType.courier) ...[
              if (delivery.courierCompany != null) ...[
                _buildInfoRow(
                  Icons.business_outlined,
                  '택배사',
                  delivery.courierCompany!,
                ),
                const SizedBox(height: 12),
              ],
              if (delivery.trackingNumber != null) ...[
                _buildInfoRow(
                  Icons.confirmation_number_outlined,
                  '송장번호',
                  delivery.trackingNumber!,
                ),
                const SizedBox(height: 12),
              ],
            ],
            
            // 직접 배송 정보
            if (delivery.deliveryType == DeliveryType.direct) ...[
              if (delivery.driverName != null) ...[
                _buildInfoRow(
                  Icons.person_outlined,
                  '기사 이름',
                  delivery.driverName!,
                ),
                const SizedBox(height: 12),
              ],
              if (delivery.driverPhone != null) ...[
                _buildInfoRow(
                  Icons.phone_outlined,
                  '기사 연락처',
                  delivery.driverPhone!,
                ),
                const SizedBox(height: 12),
              ],
              if (delivery.vehicleNumber != null) ...[
                _buildInfoRow(
                  Icons.directions_car_outlined,
                  '차량 번호',
                  delivery.vehicleNumber!,
                ),
                const SizedBox(height: 12),
              ],
            ],
            if (delivery.estimatedDeliveryDate != null) ...[
              _buildInfoRow(
                Icons.calendar_today_outlined,
                '예상 도착일',
                DateFormat('yyyy년 MM월 dd일').format(delivery.estimatedDeliveryDate!),
              ),
              const SizedBox(height: 12),
            ],
            if (delivery.shippedAt != null) ...[
              _buildInfoRow(
                Icons.schedule,
                '배송 시작',
                DateFormat('yyyy.MM.dd HH:mm').format(delivery.shippedAt!),
              ),
              const SizedBox(height: 12),
            ],
            if (delivery.deliveredAt != null) ...[
              _buildInfoRow(
                Icons.done_all,
                '배송 완료',
                DateFormat('yyyy.MM.dd HH:mm').format(delivery.deliveredAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.preparing:
        return const Color(0xFF3B82F6);
      case DeliveryStatus.shipped:
        return const Color(0xFF10B981);
      case DeliveryStatus.delivered:
        return const Color(0xFF8B5CF6);
    }
  }
}
