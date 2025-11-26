import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';

class DeliveryInfoFormPage extends StatefulWidget {
  final int productId;
  final String productName;

  const DeliveryInfoFormPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<DeliveryInfoFormPage> createState() => _DeliveryInfoFormPageState();
}

class _DeliveryInfoFormPageState extends State<DeliveryInfoFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _deliveryType = '익일배송';
  int _deliveryFee = 3000;
  int _freeDeliveryThreshold = 50000;
  String _deliveryRegions = '서울,경기,인천';
  String _deliveryDays = '월,화,수,목,금';
  String _deliveryTimeSlots = '오전,오후';
  int _estimatedDeliveryDays = 1;
  String _packagingType = '박스';
  bool _isFragile = false;
  bool _requiresRefrigeration = false;
  String? _specialInstructions;

  final List<String> _deliveryTypes = ['당일배송', '익일배송', '2-3일 배송', '주문 후 배송'];
  final List<String> _packagingTypes = ['박스', '비닐', '냉장박스', '냉동박스', '스티로폼'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '배송 정보 등록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.state == CatalogState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2BEE6C),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdownField(
                          label: '배송 유형',
                          icon: Icons.local_shipping_outlined,
                          value: _deliveryType,
                          items: _deliveryTypes,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _deliveryType = value;
                                if (value == '당일배송') {
                                  _estimatedDeliveryDays = 0;
                                } else if (value == '익일배송') {
                                  _estimatedDeliveryDays = 1;
                                } else if (value == '2-3일 배송') {
                                  _estimatedDeliveryDays = 2;
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField(
                          label: '배송비 (원)',
                          icon: Icons.payments_outlined,
                          hint: '예: 3000',
                          initialValue: _deliveryFee.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _deliveryFee = int.parse(value!),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField(
                          label: '무료 배송 기준 금액 (원)',
                          icon: Icons.card_giftcard_outlined,
                          hint: '예: 50000',
                          initialValue: _freeDeliveryThreshold.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _freeDeliveryThreshold = int.parse(value!),
                        ),
                        const SizedBox(height: 24),
                  
                        _buildTextField(
                          label: '배송 가능 지역 (쉼표로 구분)',
                          icon: Icons.fmd_good_outlined,
                          hint: '예: 서울,경기,인천',
                          initialValue: _deliveryRegions,
                          onSaved: (value) => _deliveryRegions = value!,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField(
                          label: '배송 가능 요일 (쉼표로 구분)',
                          icon: Icons.calendar_month_outlined,
                          hint: '예: 월,화,수,목,금',
                          initialValue: _deliveryDays,
                          onSaved: (value) => _deliveryDays = value!,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField(
                          label: '배송 시간대 (쉼표로 구분)',
                          icon: Icons.schedule,
                          hint: '예: 오전,오후',
                          initialValue: _deliveryTimeSlots,
                          onSaved: (value) => _deliveryTimeSlots = value!,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField(
                          label: '예상 배송 일수',
                          icon: Icons.local_shipping_outlined,
                          hint: '예: 1',
                          initialValue: _estimatedDeliveryDays.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _estimatedDeliveryDays = int.parse(value!),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildDropdownField(
                          label: '포장 유형',
                          icon: Icons.inventory_2_outlined,
                          value: _packagingType,
                          items: _packagingTypes,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _packagingType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildToggleCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.red,
                          label: '파손 주의 상품',
                          value: _isFragile,
                          onChanged: (value) {
                            setState(() => _isFragile = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildToggleCard(
                          icon: Icons.ac_unit,
                          iconColor: Colors.blue,
                          label: '냉장 보관 필요',
                          value: _requiresRefrigeration,
                          onChanged: (value) {
                            setState(() => _requiresRefrigeration = value);
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '특별 지시사항 (선택)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: '예: 1층 로비에 맡겨주세요.',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2BEE6C),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              maxLines: 4,
                              style: const TextStyle(
                                color: Color(0xFF1C1C1E),
                              ),
                              onSaved: (value) {
                                _specialInstructions = value?.isEmpty == true ? null : value;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8F6).withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF60A5FA),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '배송 정보 저장',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String hint,
    required String initialValue,
    required Function(String?) onSaved,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFF1C1C1E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF9CA3AF),
              size: 24,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF2BEE6C),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label을(를) 입력하세요';
            }
            return null;
          },
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF9CA3AF),
              size: 24,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF2BEE6C),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 16,
          ),
          dropdownColor: Colors.white,
          items: items.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: onChanged,
          onSaved: onChanged,
        ),
      ],
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2BEE6C),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 디버깅: 전송할 데이터 확인
      print('=== 배송 정보 전송 데이터 ===');
      print('productId: ${widget.productId}');
      print('deliveryType: $_deliveryType');
      print('deliveryFee: $_deliveryFee');
      print('freeDeliveryThreshold: $_freeDeliveryThreshold');
      print('deliveryRegions: $_deliveryRegions');
      print('deliveryDays: $_deliveryDays');
      print('deliveryTimeSlots: $_deliveryTimeSlots');
      print('estimatedDeliveryDays: $_estimatedDeliveryDays');
      print('packagingType: $_packagingType');
      print('isFragile: $_isFragile');
      print('requiresRefrigeration: $_requiresRefrigeration');
      print('specialInstructions: $_specialInstructions');
      print('========================');

      final provider = context.read<CatalogProvider>();
      
      try {
        await provider.createOrUpdateDeliveryInfo(
          productId: widget.productId,
          deliveryType: _deliveryType,
          deliveryFee: _deliveryFee,
          freeDeliveryThreshold: _freeDeliveryThreshold,
          deliveryRegions: _deliveryRegions,
          deliveryDays: _deliveryDays,
          deliveryTimeSlots: _deliveryTimeSlots,
          estimatedDeliveryDays: _estimatedDeliveryDays,
          packagingType: _packagingType,
          isFragile: _isFragile,
          requiresRefrigeration: _requiresRefrigeration,
          specialInstructions: _specialInstructions,
        );

        if (provider.state == CatalogState.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('배송 정보가 저장되었습니다')),
            );
            Navigator.pop(context);
          }
        } else if (provider.state == CatalogState.error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage ?? '오류가 발생했습니다'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        print('배송 정보 저장 에러: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('에러: $e'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}
