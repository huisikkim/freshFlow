import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';
import 'package:fresh_flow/presentation/providers/cart_provider.dart';
import 'package:fresh_flow/presentation/pages/cart_page.dart';
import 'package:fresh_flow/domain/entities/product.dart';
import 'package:fresh_flow/injection_container.dart';
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
  Timer? _snackBarTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadProductDetailWithDelivery(widget.productId);
    });
  }

  @override
  void dispose() {
    _snackBarTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '상품 상세 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.state == CatalogState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF10B981),
              ),
            );
          }

          if (provider.state == CatalogState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage ?? '오류가 발생했습니다',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadProductDetailWithDelivery(widget.productId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final product = provider.currentProduct;
          if (product == null) {
            return const Center(
              child: Text(
                '상품 정보를 찾을 수 없습니다',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상품 이미지
                Container(
                  margin: const EdgeInsets.all(24),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFE5E7EB),
                                  child: const Icon(
                                    Icons.image,
                                    size: 80,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: const Color(0xFFE5E7EB),
                              child: const Icon(
                                Icons.image,
                                size: 80,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상품명
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 유통업체명
                      if (product.distributorName != null)
                        Text(
                          product.distributorName!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      const SizedBox(height: 24),

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
                      
                      const SizedBox(height: 80), // 하단 버튼 공간
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          final product = provider.currentProduct;
          if (product == null) return const SizedBox.shrink();
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: product.isAvailable
                      ? () => _showAddToCartDialog(context, product)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    elevation: 0,
                    shadowColor: const Color(0xFF10B981).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        product.isAvailable ? '장바구니 담기' : '품절',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context, Product product) {
    int quantity = product.minOrderQuantity;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('장바구니에 담기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: quantity > product.minOrderQuantity
                        ? () => setState(() => quantity--)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$quantity ${product.unit}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: quantity < product.maxOrderQuantity
                        ? () => setState(() => quantity++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '최소 ${product.minOrderQuantity} ~ 최대 ${product.maxOrderQuantity} ${product.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _addToCart(context, product, quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('담기'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, Product product, int quantity) async {
    // CartProvider를 injection_container에서 가져와서 사용
    final cartProvider = InjectionContainer.getCartProvider();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // 기존 SnackBar 모두 제거
    scaffoldMessenger.clearSnackBars();
    
    try {
      // 로딩 표시
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('장바구니에 담는 중...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // 장바구니에 추가
      await cartProvider.addToCart(product.id, quantity);
      
      if (context.mounted) {
        // 로딩 SnackBar 즉시 제거
        scaffoldMessenger.clearSnackBars();
        
        // 잠시 대기 후 성공 메시지 표시
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (context.mounted) {
          // 이전 타이머 취소
          _snackBarTimer?.cancel();
          
          // 성공 메시지 표시
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('${product.productName} ${quantity}${product.unit}을(를) 장바구니에 담았습니다'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: '보기',
                textColor: Colors.white,
                onPressed: () {
                  _snackBarTimer?.cancel();
                  scaffoldMessenger.hideCurrentSnackBar();
                  // 장바구니 페이지로 이동
                  if (product.distributorId != null && product.distributorName != null) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: cartProvider,
                          child: CartPage(
                            distributorId: product.distributorId!,
                            distributorName: product.distributorName!,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          );
          
          // Timer를 사용해서 정확히 3초 후에 SnackBar 제거
          _snackBarTimer = Timer(const Duration(seconds: 3), () {
            scaffoldMessenger.clearSnackBars();
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('장바구니 담기 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
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
