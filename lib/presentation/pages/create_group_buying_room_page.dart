import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/distributor_group_buying_provider.dart';

class CreateGroupBuyingRoomPage extends StatefulWidget {
  final String distributorId;
  final String distributorName;

  const CreateGroupBuyingRoomPage({
    super.key,
    required this.distributorId,
    required this.distributorName,
  });

  @override
  State<CreateGroupBuyingRoomPage> createState() =>
      _CreateGroupBuyingRoomPageState();
}

class _CreateGroupBuyingRoomPageState extends State<CreateGroupBuyingRoomPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _roomTitleController = TextEditingController();
  final _productIdController = TextEditingController();
  final _discountRateController = TextEditingController();
  final _availableStockController = TextEditingController();
  final _targetQuantityController = TextEditingController();
  final _minOrderPerStoreController = TextEditingController();
  final _maxOrderPerStoreController = TextEditingController();
  final _minParticipantsController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _regionController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _durationHoursController = TextEditingController(text: '24');
  final _descriptionController = TextEditingController();
  final _specialNoteController = TextEditingController();

  String _deliveryFeeType = 'SHARED';
  bool _featured = false;

  InputDecoration _buildInputDecoration(String label, String hint, {int? maxLines}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF374151)),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF374151)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF1F2937),
    );
  }

  @override
  void dispose() {
    _roomTitleController.dispose();
    _productIdController.dispose();
    _discountRateController.dispose();
    _availableStockController.dispose();
    _targetQuantityController.dispose();
    _minOrderPerStoreController.dispose();
    _maxOrderPerStoreController.dispose();
    _minParticipantsController.dispose();
    _maxParticipantsController.dispose();
    _regionController.dispose();
    _deliveryFeeController.dispose();
    _durationHoursController.dispose();
    _descriptionController.dispose();
    _specialNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          '공동구매 방 만들기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF9FAFB),
          ),
        ),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '기본 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomTitleController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('방 제목 *', '예: 🔥 김치 대박 세일! 20% 할인'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '방 제목을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productIdController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('상품 ID *', '예: 1'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '상품 ID를 입력하세요';
                }
                if (int.tryParse(value) == null) {
                  return '숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '가격 및 할인',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountRateController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('할인율 (%) *', '예: 20'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '할인율을 입력하세요';
                }
                final rate = double.tryParse(value);
                if (rate == null || rate < 0 || rate > 100) {
                  return '0~100 사이의 숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '재고 및 목표',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _availableStockController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('준비한 재고 *', '예: 500'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '재고를 입력하세요';
                }
                if (int.tryParse(value) == null) {
                  return '숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetQuantityController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('목표 수량 *', '예: 300'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '목표 수량을 입력하세요';
                }
                if (int.tryParse(value) == null) {
                  return '숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '주문 제한',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minOrderPerStoreController,
                    style: const TextStyle(color: Color(0xFFF9FAFB)),
                    decoration: _buildInputDecoration('최소 주문 *', '예: 10'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '최소 주문을 입력하세요';
                      }
                      if (int.tryParse(value) == null) {
                        return '숫자를 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxOrderPerStoreController,
                    style: const TextStyle(color: Color(0xFFF9FAFB)),
                    decoration: _buildInputDecoration('최대 주문', '예: 100'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minParticipantsController,
                    style: const TextStyle(color: Color(0xFFF9FAFB)),
                    decoration: _buildInputDecoration('최소 참여자 *', '예: 5'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '최소 참여자를 입력하세요';
                      }
                      if (int.tryParse(value) == null) {
                        return '숫자를 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxParticipantsController,
                    style: const TextStyle(color: Color(0xFFF9FAFB)),
                    decoration: _buildInputDecoration('최대 참여자', '예: 20'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '배송 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regionController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('대상 지역 *', '예: 서울 강남구,서초구'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '대상 지역을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deliveryFeeController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('배송비 *', '예: 50000'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '배송비를 입력하세요';
                }
                if (double.tryParse(value) == null) {
                  return '숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _deliveryFeeType,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              dropdownColor: const Color(0xFF1F2937),
              decoration: _buildInputDecoration('배송비 타입 *', ''),
              items: const [
                DropdownMenuItem(value: 'FREE', child: Text('무료 배송')),
                DropdownMenuItem(value: 'FIXED', child: Text('고정 배송비')),
                DropdownMenuItem(value: 'SHARED', child: Text('분담 배송비')),
              ],
              onChanged: (value) {
                setState(() {
                  _deliveryFeeType = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '기간 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationHoursController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('진행 시간 (시간) *', '예: 24'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '진행 시간을 입력하세요';
                }
                if (int.tryParse(value) == null) {
                  return '숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '추가 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('설명', '신선한 김치를 특가로 제공합니다!'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialNoteController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _buildInputDecoration('특이사항', '당일 배송 보장'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF374151),
                ),
              ),
              child: SwitchListTile(
                title: const Text(
                  '추천 방으로 설정',
                  style: TextStyle(color: Color(0xFFF9FAFB)),
                ),
                subtitle: const Text(
                  '메인 페이지에 추천으로 표시됩니다',
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
                value: _featured,
                activeColor: const Color(0xFFD4AF37),
                onChanged: (value) {
                  setState(() {
                    _featured = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '공동구매 방 만들기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _createRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<DistributorGroupBuyingProvider>();
    
    final success = await provider.createGroupBuyingRoom(
      roomTitle: _roomTitleController.text,
      distributorId: widget.distributorId,
      distributorName: widget.distributorName,
      productId: int.parse(_productIdController.text),
      discountRate: double.parse(_discountRateController.text),
      availableStock: int.parse(_availableStockController.text),
      targetQuantity: int.parse(_targetQuantityController.text),
      minOrderPerStore: int.parse(_minOrderPerStoreController.text),
      minParticipants: int.parse(_minParticipantsController.text),
      region: _regionController.text,
      deliveryFee: double.parse(_deliveryFeeController.text),
      deliveryFeeType: _deliveryFeeType,
      durationHours: int.parse(_durationHoursController.text),
      maxOrderPerStore: _maxOrderPerStoreController.text.isEmpty
          ? null
          : int.parse(_maxOrderPerStoreController.text),
      maxParticipants: _maxParticipantsController.text.isEmpty
          ? null
          : int.parse(_maxParticipantsController.text),
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      specialNote: _specialNoteController.text.isEmpty
          ? null
          : _specialNoteController.text,
      featured: _featured,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공동구매 방이 생성되었습니다!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '방 생성에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
