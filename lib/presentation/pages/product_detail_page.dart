import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';
import 'package:fresh_flow/domain/entities/product.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadProductDetailWithDelivery(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 상세 정보'),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.state == CatalogState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == CatalogState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage ?? '오류가 발생했습니다'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadProductDetailWithDelivery(widget.productId);
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final product = provider.currentProduct;
          if (product == null) {
            return const Center(child: Text('상품 정보를 찾을 수 없습니다'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상품 이미지
                if (product.imageUrl != null)
                  Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 100),
                      );
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 100),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상품명
                      Text(
                        product.productName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // 유통업체명
                      if (product.distributorName != null)
                        Text(
                          product.distributorName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      const SizedBox(height: 16),

                      // 가격 정보
                      _buildInfoCard(
                        context,
                        '가격 정보',
                        [
                          _buildInfoRow('단가', product.priceInfo ?? '${numberFormat.format(product.unitPrice)}원/${product.unit}'),
                          if (product.hasDiscount == true)
                            _buildInfoRow('할인', '할인 적용 중', valueColor: Colors.red),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 재고 정보
                      _buildInfoCard(
                        context,
                        '재고 정보',
                        [
                          _buildInfoRow('재고 상태', product.stockStatus ?? _getStockStatus(product.stockQuantity)),
                          _buildInfoRow('재고 수량', '${product.stockQuantity} ${product.unit}'),
                          _buildInfoRow('판매 상태', product.isAvailable ? '판매 중' : '품절'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 주문 정보
                      _buildInfoCard(
                        context,
                        '주문 정보',
                        [
                          _buildInfoRow('주문 제한', product.orderLimitInfo ?? '최소 ${product.minOrderQuantity} ~ 최대 ${product.maxOrderQuantity} ${product.unit}'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 상품 정보
                      _buildInfoCard(
                        context,
                        '상품 정보',
                        [
                          _buildInfoRow('카테고리', product.category),
                          _buildInfoRow('원산지', product.origin),
                          _buildInfoRow('브랜드', product.brand),
                          if (product.certifications != null)
                            _buildInfoRow('인증', product.certifications!),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 상품 설명
                      Text(
                        '상품 설명',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(product.description),
                      const SizedBox(height: 16),

                      // 배송 정보
                      if (product.deliveryInfo != null)
                        _buildDeliveryInfo(context, product.deliveryInfo!),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, DeliveryInfo deliveryInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '배송 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('배송 유형', deliveryInfo.deliveryType),
            _buildInfoRow('배송비', deliveryInfo.deliveryFeeInfo),
            _buildInfoRow('예상 배송', deliveryInfo.estimatedDeliveryInfo),
            _buildInfoRow('배송 지역', deliveryInfo.deliveryRegions),
            _buildInfoRow('배송 요일', deliveryInfo.deliveryDays),
            _buildInfoRow('배송 시간', deliveryInfo.deliveryTimeSlots),
            _buildInfoRow('포장 유형', deliveryInfo.packagingType),
            if (deliveryInfo.isFragile)
              _buildInfoRow('주의사항', '파손 주의', valueColor: Colors.orange),
            if (deliveryInfo.requiresRefrigeration)
              _buildInfoRow('보관방법', '냉장 보관 필요', valueColor: Colors.blue),
            if (deliveryInfo.specialInstructions != null)
              _buildInfoRow('특별 지시사항', deliveryInfo.specialInstructions!),
          ],
        ),
      ),
    );
  }

  String _getStockStatus(int quantity) {
    if (quantity == 0) return '품절';
    if (quantity < 10) return '재고 부족';
    return '재고 충분';
  }
}
