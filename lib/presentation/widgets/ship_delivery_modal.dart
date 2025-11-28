import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShipDeliveryModal extends StatefulWidget {
  final String orderId;
  final Function({
    required String deliveryType,
    String? trackingNumber,
    String? courierCompany,
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    required DateTime estimatedDate,
  }) onShip;

  const ShipDeliveryModal({
    super.key,
    required this.orderId,
    required this.onShip,
  });

  @override
  State<ShipDeliveryModal> createState() => _ShipDeliveryModalState();
}

class _ShipDeliveryModalState extends State<ShipDeliveryModal> {
  final _formKey = GlobalKey<FormState>();
  final _trackingNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  String _deliveryType = 'COURIER'; // COURIER or DIRECT
  String _selectedCourier = 'CJ대한통운';
  DateTime _estimatedDate = DateTime.now().add(const Duration(days: 2));

  final List<String> _couriers = [
    'CJ대한통운',
    '우체국택배',
    '한진택배',
    '로젠택배',
    'GS25편의점택배',
    '쿠팡로켓배송',
  ];

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '배송 시작',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 배송 방식 선택
                const Text(
                  '배송 방식',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('택배 배송'),
                        value: 'COURIER',
                        groupValue: _deliveryType,
                        onChanged: (value) {
                          setState(() {
                            _deliveryType = value!;
                          });
                        },
                        activeColor: const Color(0xFF10B981),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('직접 배송'),
                        value: 'DIRECT',
                        groupValue: _deliveryType,
                        onChanged: (value) {
                          setState(() {
                            _deliveryType = value!;
                          });
                        },
                        activeColor: const Color(0xFF10B981),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 택배 배송 필드
                if (_deliveryType == 'COURIER') ...[
                  // 택배사 선택
                  const Text(
                    '택배사',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCourier,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _couriers.map((courier) {
                      return DropdownMenuItem(
                        value: courier,
                        child: Text(courier),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCourier = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // 송장번호 입력
                  const Text(
                    '송장번호',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _trackingNumberController,
                    decoration: InputDecoration(
                      hintText: '송장번호를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_deliveryType == 'COURIER' &&
                          (value == null || value.isEmpty)) {
                        return '송장번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ],

                // 직접 배송 필드
                if (_deliveryType == 'DIRECT') ...[
                  // 기사 이름
                  const Text(
                    '기사 이름',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _driverNameController,
                    decoration: InputDecoration(
                      hintText: '기사 이름을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (_deliveryType == 'DIRECT' &&
                          (value == null || value.isEmpty)) {
                        return '기사 이름을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 기사 연락처
                  const Text(
                    '기사 연락처',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _driverPhoneController,
                    decoration: InputDecoration(
                      hintText: '010-0000-0000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (_deliveryType == 'DIRECT' &&
                          (value == null || value.isEmpty)) {
                        return '기사 연락처를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 차량 번호
                  const Text(
                    '차량 번호',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: InputDecoration(
                      hintText: '12가3456',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (_deliveryType == 'DIRECT' &&
                          (value == null || value.isEmpty)) {
                        return '차량 번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),

                // 예상 도착일 선택
                const Text(
                  '예상 도착일',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _estimatedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF10B981),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _estimatedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(_estimatedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onShip(
                          deliveryType: _deliveryType,
                          trackingNumber: _deliveryType == 'COURIER'
                              ? _trackingNumberController.text
                              : null,
                          courierCompany: _deliveryType == 'COURIER'
                              ? _selectedCourier
                              : null,
                          driverName: _deliveryType == 'DIRECT'
                              ? _driverNameController.text
                              : null,
                          driverPhone: _deliveryType == 'DIRECT'
                              ? _driverPhoneController.text
                              : null,
                          vehicleNumber: _deliveryType == 'DIRECT'
                              ? _vehicleNumberController.text
                              : null,
                          estimatedDate: _estimatedDate,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '배송 시작',
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
}
