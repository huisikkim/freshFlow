import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/comparison_provider.dart';
import 'package:fresh_flow/domain/entities/distributor_comparison.dart';

class BestByCategoryPage extends StatefulWidget {
  final List<String> distributorIds;

  const BestByCategoryPage({
    super.key,
    required this.distributorIds,
  });

  @override
  State<BestByCategoryPage> createState() => _BestByCategoryPageState();
}

class _BestByCategoryPageState extends State<BestByCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComparisonProvider>().loadBestByCategory(widget.distributorIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        title: const Text('카테고리별 최고'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ComparisonProvider>(
        builder: (context, provider, child) {
          if (provider.state == ComparisonState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6F61),
              ),
            );
          }

          if (provider.state == ComparisonState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? '조회 실패',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.bestByCategory.isEmpty) {
            return const Center(
              child: Text('데이터가 없습니다'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (provider.bestByCategory.containsKey('OVERALL'))
                _buildCategoryCard(
                  '종합 최고',
                  Icons.emoji_events,
                  const Color(0xFFFFD700),
                  provider.bestByCategory['OVERALL']!,
                ),
              if (provider.bestByCategory.containsKey('PRICE'))
                _buildCategoryCard(
                  '가격 최고',
                  Icons.attach_money,
                  const Color(0xFF06D6A0),
                  provider.bestByCategory['PRICE']!,
                ),
              if (provider.bestByCategory.containsKey('DELIVERY'))
                _buildCategoryCard(
                  '배송 최고',
                  Icons.local_shipping,
                  const Color(0xFF3B82F6),
                  provider.bestByCategory['DELIVERY']!,
                ),
              if (provider.bestByCategory.containsKey('QUALITY'))
                _buildCategoryCard(
                  '품질 최고',
                  Icons.star,
                  const Color(0xFFF59E0B),
                  provider.bestByCategory['QUALITY']!,
                ),
              if (provider.bestByCategory.containsKey('CERTIFICATION'))
                _buildCategoryCard(
                  '인증 최고',
                  Icons.verified,
                  const Color(0xFF8B5CF6),
                  provider.bestByCategory['CERTIFICATION']!,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color color,
    DistributorComparison comparison,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comparison.distributorName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D405B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${comparison.totalScore.toStringAsFixed(1)}점',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.phone,
                  '전화번호',
                  comparison.phoneNumber,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.email,
                  '이메일',
                  comparison.email,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.attach_money,
                  '최소 주문',
                  '${_formatNumber(comparison.minOrderAmount)}원',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.local_shipping,
                  '배송',
                  '${_getDeliverySpeedText(comparison.deliverySpeed)} (${comparison.deliveryFee == 0 ? '무료' : '${_formatNumber(comparison.deliveryFee)}원'})',
                ),
                if (comparison.certifications != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.verified,
                    '인증',
                    comparison.certifications!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFA9B4C2)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3D405B),
            ),
          ),
        ),
      ],
    );
  }

  String _getDeliverySpeedText(String speed) {
    switch (speed) {
      case 'SAME_DAY':
        return '당일 배송';
      case 'NEXT_DAY':
        return '익일 배송';
      case 'TWO_TO_THREE_DAYS':
        return '2-3일 배송';
      case 'OVER_THREE_DAYS':
        return '3일 이상';
      default:
        return speed;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
