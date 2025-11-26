import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/matching_provider.dart';
import 'package:fresh_flow/presentation/providers/quote_request_provider.dart';
import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';
import 'package:fresh_flow/presentation/pages/distributor_comparison_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_catalog_page.dart';
import 'package:fresh_flow/injection_container.dart';

class DistributorRecommendationsPage extends StatefulWidget {
  const DistributorRecommendationsPage({super.key});

  @override
  State<DistributorRecommendationsPage> createState() =>
      _DistributorRecommendationsPageState();
}

class _DistributorRecommendationsPageState
    extends State<DistributorRecommendationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchingProvider>().loadRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: '유통업체 비교',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => InjectionContainer.getComparisonProvider(),
                    child: const DistributorComparisonPage(topN: 5),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MatchingProvider>(
        builder: (context, matchingProvider, child) {
          if (matchingProvider.state == MatchingState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6F61),
              ),
            );
          }

          if (matchingProvider.state == MatchingState.error) {
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
                      matchingProvider.errorMessage ?? '추천 조회에 실패했습니다',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        matchingProvider.loadRecommendations();
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

          if (matchingProvider.recommendations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: Color(0xFFA9B4C2),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '추천할 유통업체가 없습니다',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D405B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '아직 등록된 유통업체가 없거나\n매장 정보와 일치하는 업체가 없습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA9B4C2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('홈으로 돌아가기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F61),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchingProvider.recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = matchingProvider.recommendations[index];
              return _buildRecommendationCard(recommendation);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(DistributorRecommendation recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 업체명 + 점수
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    recommendation.distributorName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(recommendation.totalScore),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${recommendation.totalScore.toStringAsFixed(1)}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 매칭 이유 박스
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Color(0xFF06D6A0),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recommendation.matchReason,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF065F46),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 점수 상세
            _buildScoreRow(
              '지역 매칭',
              recommendation.regionScore,
              Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildScoreRow(
              '품목 매칭',
              recommendation.productScore,
              Icons.inventory_2,
            ),
            const SizedBox(height: 12),
            _buildScoreRow(
              '배송 가능',
              recommendation.deliveryScore,
              Icons.local_shipping,
            ),
            const SizedBox(height: 12),
            _buildScoreRow(
              '인증',
              recommendation.certificationScore,
              Icons.verified,
            ),
            
            const Divider(height: 32, thickness: 1),
            
            // 상세 정보
            _buildInfoRow(
              Icons.shopping_bag,
              '공급 품목',
              recommendation.supplyProducts,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.map,
              '서비스 지역',
              recommendation.serviceRegions,
            ),
            const SizedBox(height: 10),
            if (recommendation.certifications != null &&
                recommendation.certifications!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildInfoRow(
                  Icons.shield,
                  '인증',
                  recommendation.certifications!,
                ),
              ),
            _buildInfoRow(
              Icons.payments,
              '최소 주문 금액',
              '${_formatNumber(recommendation.minOrderAmount)}원',
            ),
            if (recommendation.deliveryAvailable &&
                recommendation.deliveryInfo != null &&
                recommendation.deliveryInfo!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildInfoRow(
                Icons.local_shipping,
                '배송 정보',
                recommendation.deliveryInfo!,
              ),
            ],
            
            const SizedBox(height: 20),
            
            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => InjectionContainer.getCatalogProvider(),
                            child: DistributorCatalogPage(
                              distributorId: recommendation.distributorId,
                              distributorName: recommendation.distributorName,
                            ),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shopping_cart, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '상품 보기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showQuoteRequestDialog(context, recommendation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '견적 요청',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: 전화 걸기
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            recommendation.phoneNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: 이메일 보내기
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B6B),
                      side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.mail, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '이메일',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 38,
          child: Text(
            '${score.toStringAsFixed(0)}점',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981); // Green
    if (score >= 60) return const Color(0xFFF59E0B); // Orange
    if (score >= 40) return const Color(0xFFFF6B6B); // Red/Coral
    return const Color(0xFF9CA3AF); // Gray
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showQuoteRequestDialog(
      BuildContext context, DistributorRecommendation recommendation) {
    final messageController = TextEditingController();
    final selectedProducts = <String>[];
    final availableProducts = recommendation.supplyProducts.split(',');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${recommendation.distributorName}에 견적 요청'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '요청 품목 선택',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableProducts.map((product) {
                    final isSelected = selectedProducts.contains(product);
                    return FilterChip(
                      label: Text(product.trim()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedProducts.add(product.trim());
                          } else {
                            selectedProducts.remove(product.trim());
                          }
                        });
                      },
                      selectedColor: const Color(0xFFFF6F61).withOpacity(0.3),
                      checkmarkColor: const Color(0xFFFF6F61),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  '추가 요청사항',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '예: 매주 월요일 오전 배송 가능한지 확인 부탁드립니다.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: selectedProducts.isEmpty
                  ? null
                  : () async {
                      final quoteProvider =
                          InjectionContainer.getQuoteRequestProvider();
                      await quoteProvider.createQuoteRequest(
                        distributorId: recommendation.distributorId,
                        requestedProducts: selectedProducts.join(','),
                        message: messageController.text.isEmpty
                            ? null
                            : messageController.text,
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      if (context.mounted) {
                        if (quoteProvider.state == QuoteRequestState.success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('견적 요청이 전송되었습니다'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (quoteProvider.state ==
                            QuoteRequestState.error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(quoteProvider.errorMessage ??
                                  '견적 요청 실패'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F61),
                foregroundColor: Colors.white,
              ),
              child: const Text('견적 요청'),
            ),
          ],
        ),
      ),
    );
  }
}
