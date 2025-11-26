import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/comparison_provider.dart';
import 'package:fresh_flow/domain/entities/distributor_comparison.dart';
import 'package:fresh_flow/presentation/pages/comparison_table_page.dart';
import 'package:fresh_flow/presentation/pages/best_by_category_page.dart';
import 'package:fresh_flow/injection_container.dart';

class DistributorComparisonPage extends StatefulWidget {
  final int topN;

  const DistributorComparisonPage({
    super.key,
    this.topN = 5,
  });

  @override
  State<DistributorComparisonPage> createState() =>
      _DistributorComparisonPageState();
}

class _DistributorComparisonPageState
    extends State<DistributorComparisonPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComparisonProvider>().loadTopComparisons(topN: widget.topN);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        title: Text('유통업체 비교 (Top ${widget.topN})'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<ComparisonProvider>()
                  .loadTopComparisons(topN: widget.topN);
            },
          ),
        ],
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
                      provider.errorMessage ?? '비교 조회 실패',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        provider.loadTopComparisons(topN: widget.topN);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F61),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.comparisons.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 80,
                    color: Color(0xFFA9B4C2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '비교할 유통업체가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D405B),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildActionButtons(provider.comparisons),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.comparisons.length,
                  itemBuilder: (context, index) {
                    return _buildComparisonCard(provider.comparisons[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(List<DistributorComparison> comparisons) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ComparisonTablePage(
                      comparisons: comparisons,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.table_chart, size: 18),
              label: const Text('비교표 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6F61),
                side: const BorderSide(color: Color(0xFFFF6F61)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                final ids =
                    comparisons.map((c) => c.distributorId).toList();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => InjectionContainer.getComparisonProvider(),
                      child: BestByCategoryPage(distributorIds: ids),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.emoji_events, size: 18),
              label: const Text('카테고리별 최고'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF06D6A0),
                side: const BorderSide(color: Color(0xFF06D6A0)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(DistributorComparison comparison) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildRankBadge(comparison.rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comparison.distributorName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D405B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(comparison.totalScore),
                          const SizedBox(width: 8),
                          Text(
                            '${comparison.totalScore.toStringAsFixed(1)}점',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6F61),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildBestCategoryBadge(comparison.bestCategory),
              ],
            ),
            const Divider(height: 24),
            _buildInfoSection('가격', Icons.attach_money, [
              '${_getPriceLevelText(comparison.priceLevel)} (${_formatNumber(comparison.minOrderAmount)}원~)',
              comparison.priceNote,
            ]),
            const SizedBox(height: 12),
            _buildInfoSection('배송', Icons.local_shipping, [
              '${_getDeliverySpeedText(comparison.deliverySpeed)} (${comparison.deliveryFee == 0 ? '무료' : '${_formatNumber(comparison.deliveryFee)}원'})',
              if (comparison.deliveryInfo != null) comparison.deliveryInfo!,
            ]),
            const SizedBox(height: 12),
            _buildInfoSection('품질', Icons.star, [
              '${_getQualityRatingText(comparison.qualityRating)} (신뢰도 ${comparison.reliabilityScore.toStringAsFixed(0)}점)',
            ]),
            const SizedBox(height: 12),
            _buildInfoSection('인증', Icons.verified, [
              comparison.certifications ?? '인증 없음',
              '${comparison.certificationCount}개 보유',
            ]),
            if (comparison.strengths.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                '강점',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06D6A0),
                ),
              ),
              const SizedBox(height: 8),
              ...comparison.strengths.map((strength) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF06D6A0),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strength,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3D405B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            if (comparison.weaknesses.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '약점',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA9B4C2),
                ),
              ),
              const SizedBox(height: 8),
              ...comparison.weaknesses.map((weakness) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFFA9B4C2),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            weakness,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    if (rank == 1) {
      color = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      color = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      color = const Color(0xFFCD7F32); // Bronze
    } else {
      color = const Color(0xFFA9B4C2);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank위',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(double score) {
    final stars = (score / 20).round();
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < stars ? Icons.star : Icons.star_border,
          size: 16,
          color: const Color(0xFFFFD700),
        ),
      ),
    );
  }

  Widget _buildBestCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF06D6A0).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 14,
            color: Color(0xFF06D6A0),
          ),
          const SizedBox(width: 4),
          Text(
            _getBestCategoryText(category),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF06D6A0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFFF6F61)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D405B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 26, top: 2),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            )),
      ],
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

  String _getBestCategoryText(String category) {
    switch (category) {
      case 'PRICE':
        return '가격 최고';
      case 'DELIVERY':
        return '배송 최고';
      case 'QUALITY':
        return '품질 최고';
      case 'SERVICE':
        return '서비스 최고';
      case 'CERTIFICATION':
        return '인증 최고';
      default:
        return category;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
