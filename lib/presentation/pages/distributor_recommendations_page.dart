import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/matching_provider.dart';
import 'package:fresh_flow/presentation/providers/quote_request_provider.dart';
import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';
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
        title: const Text('맞춤 유통업체 추천'),
        backgroundColor: Colors.white,
        elevation: 0,
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recommendation.distributorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D405B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(recommendation.totalScore),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recommendation.totalScore.toStringAsFixed(1)}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF06D6A0),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.matchReason,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3D405B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildScoreRow(
              '지역 매칭',
              recommendation.regionScore,
              Icons.location_on,
            ),
            const SizedBox(height: 8),
            _buildScoreRow(
              '품목 매칭',
              recommendation.productScore,
              Icons.inventory_2,
            ),
            const SizedBox(height: 8),
            _buildScoreRow(
              '배송 가능',
              recommendation.deliveryScore,
              Icons.local_shipping,
            ),
            const SizedBox(height: 8),
            _buildScoreRow(
              '인증',
              recommendation.certificationScore,
              Icons.verified,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.shopping_bag,
              '공급 품목',
              recommendation.supplyProducts,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.map,
              '서비스 지역',
              recommendation.serviceRegions,
            ),
            const SizedBox(height: 8),
            if (recommendation.certifications != null &&
                recommendation.certifications!.isNotEmpty)
              _buildInfoRow(
                Icons.verified_user,
                '인증',
                recommendation.certifications!,
              ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.attach_money,
              '최소 주문 금액',
              '${_formatNumber(recommendation.minOrderAmount)}원',
            ),
            if (recommendation.deliveryAvailable &&
                recommendation.deliveryInfo != null &&
                recommendation.deliveryInfo!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.local_shipping,
                '배송 정보',
                recommendation.deliveryInfo!,
              ),
            ],
            const Divider(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showQuoteRequestDialog(context, recommendation);
              },
              icon: const Icon(Icons.request_quote, size: 20),
              label: const Text('견적 요청하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F61),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 전화 걸기
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text(recommendation.phoneNumber),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF06D6A0),
                      side: const BorderSide(color: Color(0xFF06D6A0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 이메일 보내기
                    },
                    icon: const Icon(Icons.email, size: 18),
                    label: const Text('이메일'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6F61),
                      side: const BorderSide(color: Color(0xFFFF6F61)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
        Icon(icon, size: 16, color: const Color(0xFFA9B4C2)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF3D405B),
          ),
        ),
        const Spacer(),
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${score.toStringAsFixed(0)}점',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D405B),
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
        Icon(icon, size: 16, color: const Color(0xFFA9B4C2)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3D405B),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
    if (score >= 80) return const Color(0xFF06D6A0);
    if (score >= 60) return const Color(0xFFFFB84D);
    return const Color(0xFFFF6F61);
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
