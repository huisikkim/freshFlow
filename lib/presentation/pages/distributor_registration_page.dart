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
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDistributorInfo();
    });
  }

  Future<void> _loadDistributorInfo() async {
    final distributorProvider = context.read<DistributorProvider>();
    await distributorProvider.loadDistributorInfo();
    
    if (distributorProvider.distributor != null) {
      final distributor = distributorProvider.distributor!;
      setState(() {
        _isEditMode = true;
        _distributorNameController.text = distributor.distributorName;
        _supplyProductsController.text = distributor.supplyProducts;
        _serviceRegionsController.text = distributor.serviceRegions;
        _deliveryInfoController.text = distributor.deliveryInfo;
        _descriptionController.text = distributor.description;
        _certificationsController.text = distributor.certifications;
        _minOrderAmountController.text = distributor.minOrderAmount.toString();
        _operatingHoursController.text = distributor.operatingHours;
        _phoneNumberController.text = distributor.phoneNumber;
        _emailController.text = distributor.email;
        _addressController.text = distributor.address;
        _deliveryAvailable = distributor.deliveryAvailable;
      });
    }
  }

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
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(
          _isEditMode ? '유통업체 정보 수정' : '유통업자 정보 등록',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE5E7EB),
          ),
        ),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE5E7EB)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<DistributorProvider>(
          builder: (context, distributorProvider, child) {
            if (distributorProvider.state == DistributorState.success) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isEditMode 
                        ? '유통업체 정보가 수정되었습니다' 
                        : '유통업자 정보가 성공적으로 등록되었습니다'
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(true);
              });
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _supplyProductsController,
                            label: '공급 품목',
                            hint: '예: 쌀/곡물,채소,과일,육류,수산물',
                            icon: Icons.inventory_2_outlined,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _serviceRegionsController,
                            label: '서비스 지역',
                            hint: '예: 서울,경기,인천',
                            icon: Icons.map_outlined,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _certificationsController,
                            label: '인증 사항',
                            hint: '예: HACCP,ISO22000',
                            icon: Icons.verified_user_outlined,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _minOrderAmountController,
                            label: '최소 주문 금액 (원)',
                            hint: '예: 100000',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _operatingHoursController,
                            label: '운영 시간',
                            hint: '예: 09:00-18:00',
                            icon: Icons.schedule,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _phoneNumberController,
                            label: '전화번호',
                            hint: '예: 010-9876-5432',
                            icon: Icons.call,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _emailController,
                            label: '이메일',
                            hint: '예: distributor1@example.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _addressController,
                            label: '주소',
                            hint: '예: 서울시 송파구 올림픽로 456',
                            icon: Icons.home_outlined,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  color: Color(0xFFA0A0A0),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '배송 가능 여부',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFA0A0A0),
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
                                  activeColor: const Color(0xFFD4AF37),
                                  activeTrackColor: const Color(0xFFD4AF37).withOpacity(0.5),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: const Color(0xFF374151),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _deliveryInfoController,
                            label: '배송 정보',
                            hint: '예: 배송비 무료 (10만원 이상), 익일 배송',
                            icon: Icons.info_outline,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _descriptionController,
                            label: '업체 설명',
                            hint: '예: 신선한 식자재를 공급하는 전문 유통업체입니다',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                          if (distributorProvider.state == DistributorState.error)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
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
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  color: const Color(0xFF111827),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          distributorProvider.state == DistributorState.loading
                              ? null
                              : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFFD4AF37).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFFD4AF37).withOpacity(0.2),
                      ),
                      child:
                          distributorProvider.state == DistributorState.loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                )
                              : Text(
                                  _isEditMode ? '유통업체 정보 수정' : '유통업자 정보 등록',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                    ),
                  ),
                ),
              ],
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA0A0A0),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFFF5F5F5),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                icon,
                color: const Color(0xFFA0A0A0),
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
            ),
            filled: true,
            fillColor: const Color(0xFF1F2937),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD4AF37),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 12,
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFFEF4444),
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
