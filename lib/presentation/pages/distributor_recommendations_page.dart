import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/matching_provider.dart';
import 'package:fresh_flow/presentation/providers/quote_request_provider.dart';
import 'package:fresh_flow/presentation/providers/store_provider.dart';
import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';
import 'package:fresh_flow/presentation/pages/distributor_comparison_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_catalog_page.dart';
import 'package:fresh_flow/presentation/pages/store_registration_page.dart';
import 'package:fresh_flow/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('전화를 걸 수 없습니다'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('전화 연결 실패: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: const Text(
          '유통업체 찾기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF9FAFB),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: '유통업체 비교',
            color: const Color(0xFFD4AF37),
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
                color: Color(0xFFD4AF37),
              ),
            );
          }

          if (matchingProvider.state == MatchingState.error) {
            final errorMsg = matchingProvider.errorMessage ?? '';
            
            // 500 에러이거나 매장 관련 키워드가 포함된 경우 매장 정보 등록 안내
            final isStoreNotFound = errorMsg.contains('500') ||
                                   errorMsg.contains('매장을 찾을 수 없습니다') || 
                                   errorMsg.contains('매장 정보') ||
                                   errorMsg.contains('매장이 등록되지') ||
                                   errorMsg.contains('Store not found') ||
                                   errorMsg.contains('IllegalArgumentException');
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '매장 정보가 등록되지 않았습니다',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF9FAFB),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '유통업체를 추천받으려면\n먼저 매장 정보를 등록해주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => InjectionContainer.getStoreProvider(),
                              child: const StoreRegistrationPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.store),
                      label: const Text('매장 정보 등록하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF1F2937),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('홈으로 돌아가기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9CA3AF),
                        side: const BorderSide(
                          color: Color(0xFF374151),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
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
                      color: Color(0xFF4B5563),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '추천할 유통업체가 없습니다',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF9FAFB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '아직 등록된 유통업체가 없거나\n매장 정보와 일치하는 업체가 없습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
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
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF1F2937),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF9FAFB),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(recommendation.totalScore).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getScoreColor(recommendation.totalScore),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${recommendation.totalScore.toStringAsFixed(1)}점',
                    style: TextStyle(
                      color: _getScoreColor(recommendation.totalScore),
                      fontWeight: FontWeight.w700,
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
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recommendation.matchReason,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE5E7EB),
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
            ElevatedButton(
              onPressed: () {
                _showQuoteRequestDialog(context, recommendation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1F2937),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '견적 요청',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(
                        color: Color(0xFFD4AF37),
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  child: OutlinedButton(
                    onPressed: () {
                      _makePhoneCall(recommendation.phoneNumber);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9CA3AF),
                      side: const BorderSide(
                        color: Color(0xFF374151),
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.call, size: 18),
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
        Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
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
              color: Color(0xFFF9FAFB),
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
        Icon(icon, size: 18, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE5E7EB),
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
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀
                Text(
                  '${recommendation.distributorName}에 견적 요청',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF9FAFB),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // 컨텐츠
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 요청 품목 선택
                        const Text(
                          '요청 품목 선택',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableProducts.map((product) {
                            final isSelected = selectedProducts.contains(product.trim());
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedProducts.remove(product.trim());
                                  } else {
                                    selectedProducts.add(product.trim());
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFD4AF37)
                                      : const Color(0xFF111827),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFD4AF37)
                                        : const Color(0xFF374151),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  product.trim(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF1F2937)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        
                        // 추가 요청사항
                        const Text(
                          '추가 요청사항',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: messageController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFF9FAFB),
                          ),
                          decoration: InputDecoration(
                            hintText: '예: 매주 월요일 오전 배송 가능한지 확인 부탁드립니다.',
                            hintStyle: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF111827),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFD4AF37),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9CA3AF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
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
                                        backgroundColor: Color(0xFFD4AF37),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else if (quoteProvider.state ==
                                      QuoteRequestState.error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(quoteProvider.errorMessage ??
                                            '견적 요청 실패'),
                                        backgroundColor: const Color(0xFFEF4444),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF1F2937),
                          disabledBackgroundColor: const Color(0xFF374151),
                          disabledForegroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '견적 요청',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
