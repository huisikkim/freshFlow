import 'package:flutter/material.dart';
import 'package:fresh_flow/domain/entities/distributor_comparison.dart';

class ComparisonTablePage extends StatelessWidget {
  final List<DistributorComparison> comparisons;

  const ComparisonTablePage({
    super.key,
    required this.comparisons,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        title: const Text('비교표'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildComparisonTable(),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Table(
      border: TableBorder.all(
        color: const Color(0xFFE5E7EB),
        width: 1,
      ),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        _buildHeaderRow(),
        _buildRow('종합 점수', (c) => '${c.totalScore.toStringAsFixed(1)}점',
            isBest: (c) => c.totalScore),
        _buildRow('순위', (c) => '${c.rank}위'),
        _buildRow('가격대', (c) => _getPriceLevelText(c.priceLevel)),
        _buildRow('최소 주문', (c) => '${_formatNumber(c.minOrderAmount)}원',
            isBest: (c) => -c.minOrderAmount.toDouble()),
        _buildRow('배송 속도', (c) => _getDeliverySpeedText(c.deliverySpeed)),
        _buildRow('배송비', (c) => c.deliveryFee == 0 ? '무료' : '${_formatNumber(c.deliveryFee)}원',
            isBest: (c) => -c.deliveryFee.toDouble()),
        _buildRow('품질 등급', (c) => _getQualityRatingText(c.qualityRating)),
        _buildRow('신뢰도', (c) => '${c.reliabilityScore.toStringAsFixed(0)}점',
            isBest: (c) => c.reliabilityScore),
        _buildRow('인증 개수', (c) => '${c.certificationCount}개',
            isBest: (c) => c.certificationCount.toDouble()),
        _buildRow('운영 시간', (c) => c.operatingHours),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFFF6F61),
      ),
      children: [
        _buildHeaderCell('항목'),
        ...comparisons.map((c) => _buildHeaderCell(c.distributorName)),
      ],
    );
  }

  TableRow _buildRow(
    String label,
    String Function(DistributorComparison) getValue, {
    double Function(DistributorComparison)? isBest,
  }) {
    double? bestValue;
    if (isBest != null) {
      bestValue = comparisons.map(isBest).reduce((a, b) => a > b ? a : b);
    }

    return TableRow(
      children: [
        _buildCell(label, isLabel: true),
        ...comparisons.map((c) {
          final value = getValue(c);
          final isBestCell = isBest != null && isBest(c) == bestValue;
          return _buildCell(value, isBest: isBestCell);
        }),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(String text, {bool isLabel = false, bool isBest = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBest
            ? const Color(0xFF06D6A0).withOpacity(0.2)
            : isLabel
                ? const Color(0xFFF3F4F6)
                : Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isLabel || isBest ? FontWeight.bold : FontWeight.normal,
          color: isBest
              ? const Color(0xFF06D6A0)
              : isLabel
                  ? const Color(0xFF3D405B)
                  : const Color(0xFF6B7280),
        ),
        textAlign: isLabel ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  String _getPriceLevelText(String level) {
    switch (level) {
      case 'LOW':
        return '저렴';
      case 'MEDIUM':
        return '보통';
      case 'HIGH':
        return '비쌈';
      default:
        return level;
    }
  }

  String _getDeliverySpeedText(String speed) {
    switch (speed) {
      case 'SAME_DAY':
        return '당일';
      case 'NEXT_DAY':
        return '익일';
      case 'TWO_TO_THREE_DAYS':
        return '2-3일';
      case 'OVER_THREE_DAYS':
        return '3일+';
      default:
        return speed;
    }
  }

  String _getQualityRatingText(String rating) {
    switch (rating) {
      case 'EXCELLENT':
        return '최상';
      case 'GOOD':
        return '상';
      case 'AVERAGE':
        return '중';
      case 'BELOW_AVERAGE':
        return '하';
      default:
        return rating;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
