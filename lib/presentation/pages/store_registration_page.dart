import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/store_provider.dart';
import 'package:fresh_flow/presentation/pages/distributor_recommendations_page.dart';
import 'package:fresh_flow/injection_container.dart';

class StoreRegistrationPage extends StatefulWidget {
  const StoreRegistrationPage({super.key});

  @override
  State<StoreRegistrationPage> createState() => _StoreRegistrationPageState();
}

class _StoreRegistrationPageState extends State<StoreRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _regionController = TextEditingController();
  final _mainProductsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _storeNameController.dispose();
    _businessTypeController.dispose();
    _regionController.dispose();
    _mainProductsController.dispose();
    _descriptionController.dispose();
    _employeeCountController.dispose();
    _operatingHoursController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final storeProvider = context.read<StoreProvider>();
      storeProvider.registerStore(
        storeName: _storeNameController.text,
        businessType: _businessTypeController.text,
        region: _regionController.text,
        mainProducts: _mainProductsController.text,
        description: _descriptionController.text,
        employeeCount: int.parse(_employeeCountController.text),
        operatingHours: _operatingHoursController.text,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '매장 등록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: Consumer<StoreProvider>(
          builder: (context, storeProvider, child) {
            if (storeProvider.state == StoreState.success) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) =>
                          InjectionContainer.getMatchingProvider(),
                      child: const DistributorRecommendationsPage(),
                    ),
                  ),
                );
              });
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _storeNameController,
                            label: '매장명',
                            hint: '예: 맛있는 한식당',
                            icon: Icons.store,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _businessTypeController,
                            label: '업종',
                            hint: '예: 한식',
                            icon: Icons.restaurant,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _regionController,
                            label: '지역',
                            hint: '예: 서울 강남구',
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _mainProductsController,
                            label: '취급 품목',
                            hint: '예: 쌀/곡물, 채소, 육류',
                            icon: Icons.category,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _descriptionController,
                            label: '매장 설명',
                            hint: '예: 정성을 다하는 한식당입니다',
                            icon: Icons.description,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _employeeCountController,
                            label: '직원 수',
                            hint: '예: 5',
                            icon: Icons.groups,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _operatingHoursController,
                            label: '영업 시간',
                            hint: '예: 09:00-22:00',
                            icon: Icons.schedule,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _phoneNumberController,
                            label: '전화번호',
                            hint: '예: 010-1234-5678',
                            icon: Icons.call,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _addressController,
                            label: '주소',
                            hint: '예: 서울시 강남구 테헤란로 123',
                            icon: Icons.home,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (storeProvider.state == StoreState.error)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            storeProvider.errorMessage ?? '매장 등록에 실패했습니다',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: storeProvider.state == StoreState.loading
                              ? null
                              : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97066),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFF97066).withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: const Color(0xFFF97066).withOpacity(0.3),
                          ),
                          child: storeProvider.state == StoreState.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '매장 등록',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                icon,
                color: const Color(0xFF9CA3AF),
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
            ),
            filled: true,
            fillColor: Colors.white,
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
                color: Color(0xFFF97066),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
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
            if (label == '직원 수' && int.tryParse(value) == null) {
              return '숫자를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }
}
