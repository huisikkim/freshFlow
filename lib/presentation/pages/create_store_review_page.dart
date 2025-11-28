import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/domain/entities/order.dart';
import 'package:fresh_flow/presentation/providers/review_provider.dart';

class CreateStoreReviewPage extends StatefulWidget {
  final Order order;

  const CreateStoreReviewPage({super.key, required this.order});

  @override
  State<CreateStoreReviewPage> createState() => _CreateStoreReviewPageState();
}

class _CreateStoreReviewPageState extends State<CreateStoreReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  int _rating = 5;
  int _deliveryQuality = 5;
  int _productQuality = 5;
  int _serviceQuality = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          '리뷰 작성',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 유통업자 정보
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.distributorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '주문번호: ${widget.order.id}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 전체 평점
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '전체 평점',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              onPressed: () {
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                              icon: Icon(
                                index < _rating ? Icons.star : Icons.star_border,
                                size: 40,
                                color: const Color(0xFFFBBF24),
                              ),
                            );
                          }),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$_rating / 5',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 세부 평점
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '세부 평점',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRating(
                        '배송 품질',
                        _deliveryQuality,
                        (value) => setState(() => _deliveryQuality = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRating(
                        '상품 품질',
                        _productQuality,
                        (value) => setState(() => _productQuality = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRating(
                        '서비스 품질',
                        _serviceQuality,
                        (value) => setState(() => _serviceQuality = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 리뷰 내용
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '리뷰 내용',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: '거래 경험을 자세히 작성해주세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '리뷰 내용을 입력해주세요';
                          }
                          if (value.trim().length < 10) {
                            return '최소 10자 이상 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 제출 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '리뷰 작성 완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRating(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onChanged(index + 1),
              icon: Icon(
                index < value ? Icons.star : Icons.star_border,
                size: 24,
                color: const Color(0xFFFBBF24),
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.order.dbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주문 ID를 찾을 수 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reviewProvider = context.read<ReviewProvider>();
    final success = await reviewProvider.createStoreReview(
      orderId: widget.order.dbId!,
      rating: _rating,
      comment: _commentController.text.trim(),
      deliveryQuality: _deliveryQuality,
      productQuality: _productQuality,
      serviceQuality: _serviceQuality,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('리뷰가 작성되었습니다'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reviewProvider.errorMessage ?? '리뷰 작성 실패'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
