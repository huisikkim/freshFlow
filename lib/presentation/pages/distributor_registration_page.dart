import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/distributor_provider.dart';

class DistributorRegistrationPage extends StatefulWidget {
  const DistributorRegistrationPage({super.key});

  @override
  State<DistributorRegistrationPage> createState() =>
      _DistributorRegistrationPageState();
}

class _DistributorRegistrationPageState
    extends State<DistributorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _distributorNameController = TextEditingController();
  final _supplyProductsController = TextEditingController();
  final _serviceRegionsController = TextEditingController();
  final _deliveryInfoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _deliveryAvailable = true;

  @override
  void dispose() {
    _distributorNameController.dispose();
    _supplyProductsController.dispose();
    _serviceRegionsController.dispose();
    _deliveryInfoController.dispose();
    _descriptionController.dispose();
    _certificationsController.dispose();
    _minOrderAmountController.dispose();
    _operatingHoursController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final distributorProvider = context.read<DistributorProvider>();
      distributorProvider.registerDistributor(
        distributorName: _distributorNameController.text,
        supplyProducts: _supplyProductsController.text,
        serviceRegions: _serviceRegionsController.text,
        deliveryAvailable: _deliveryAvailable,
        deliveryInfo: _deliveryInfoController.text,
        description: _descriptionController.text,
        certifications: _certificationsController.text,
        minOrderAmount: int.parse(_minOrderAmountController.text),
        operatingHours: _operatingHoursController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        address: _addressController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        title: const Text('유통업자 정보 등록'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<DistributorProvider>(
          builder: (context, distributorProvider, child) {
            if (distributorProvider.state == DistributorState.success) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('유통업자 정보가 성공적으로 등록되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _distributorNameController,
                      label: '유통업체명',
                      hint: '예: 신선식자재 유통',
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _supplyProductsController,
                      label: '공급 품목',
                      hint: '예: 쌀/곡물,채소,과일,육류,수산물',
                      icon: Icons.inventory,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _serviceRegionsController,
                      label: '서비스 지역',
                      hint: '예: 서울,경기,인천',
                      icon: Icons.map,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping,
                            color: Color(0xFFA9B4C2),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '배송 가능 여부',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D405B),
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _deliveryAvailable,
                            onChanged: (value) {
                              setState(() {
                                _deliveryAvailable = value;
                              });
                            },
                            activeTrackColor: const Color(0xFF06D6A0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _deliveryInfoController,
                      label: '배송 정보',
                      hint: '예: 배송비 무료 (10만원 이상), 익일 배송',
                      icon: Icons.info_outline,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: '업체 설명',
                      hint: '예: 신선한 식자재를 공급하는 전문 유통업체입니다',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _certificationsController,
                      label: '인증 사항',
                      hint: '예: HACCP,ISO22000',
                      icon: Icons.verified,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _minOrderAmountController,
                      label: '최소 주문 금액 (원)',
                      hint: '예: 100000',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _operatingHoursController,
                      label: '운영 시간',
                      hint: '예: 09:00-18:00',
                      icon: Icons.access_time,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneNumberController,
                      label: '전화번호',
                      hint: '예: 010-9876-5432',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: '이메일',
                      hint: '예: distributor1@example.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: '주소',
                      hint: '예: 서울시 송파구 올림픽로 456',
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 24),
                    if (distributorProvider.state == DistributorState.error)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          distributorProvider.errorMessage ??
                              '유통업자 정보 등록에 실패했습니다',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed:
                          distributorProvider.state == DistributorState.loading
                              ? null
                              : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F61),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child:
                          distributorProvider.state == DistributorState.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  '유통업자 정보 등록',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
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
            color: Color(0xFF3D405B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFA9B4C2),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFA9B4C2),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF6F61),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label을(를) 입력해주세요';
            }
            if (label == '최소 주문 금액 (원)' && int.tryParse(value) == null) {
              return '숫자를 입력해주세요';
            }
            if (label == '이메일' && !value.contains('@')) {
              return '올바른 이메일 주소를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }
}
