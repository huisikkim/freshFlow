import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/pages/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNumberController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'STORE_OWNER';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNumberController.dispose();
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 일치하지 않습니다'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      authProvider.signUp(
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        userType: _selectedUserType,
        businessNumber: _businessNumberController.text,
        businessName: _businessNameController.text,
        ownerName: _ownerNameController.text,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.state == AuthState.authenticated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  });
                }

                return Container(
                  constraints: const BoxConstraints(maxWidth: 448),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.eco,
                              color: Color(0xFF06D6A0),
                              size: 36,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'FreshFlow',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3D405B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Welcome text
                        const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3D405B),
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // User Type Selection
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '사용자 유형',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D405B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedUserType,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.business,
                                  color: Color(0xFFA9B4C2),
                                  size: 24,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'STORE_OWNER',
                                  child: Text('가게 사장님'),
                                ),
                                DropdownMenuItem(
                                  value: 'DISTRIBUTOR',
                                  child: Text('유통업자'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedUserType = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Username
                        _buildTextField(
                          label: '사용자명',
                          controller: _usernameController,
                          hint: '사용자명을 입력하세요',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '사용자명을 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Email
                        _buildTextField(
                          label: '이메일',
                          controller: _emailController,
                          hint: '이메일을 입력하세요',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            if (!value.contains('@')) {
                              return '올바른 이메일 주소를 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Password
                        _buildTextField(
                          label: '비밀번호',
                          controller: _passwordController,
                          hint: '비밀번호를 입력하세요',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFFA9B4C2),
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            if (value.length < 6) {
                              return '비밀번호는 최소 6자 이상이어야 합니다';
                            }
                            return null;
                          },
                        ),

                        // Confirm Password
                        _buildTextField(
                          label: '비밀번호 확인',
                          controller: _confirmPasswordController,
                          hint: '비밀번호를 다시 입력하세요',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFFA9B4C2),
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 다시 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Business Number
                        _buildTextField(
                          label: '사업자 번호',
                          controller: _businessNumberController,
                          hint: '123-45-67890',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '사업자 번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Business Name
                        _buildTextField(
                          label: '상호명',
                          controller: _businessNameController,
                          hint: '상호명을 입력하세요',
                          icon: Icons.store_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '상호명을 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Owner Name
                        _buildTextField(
                          label: '대표자명',
                          controller: _ownerNameController,
                          hint: '대표자명을 입력하세요',
                          icon: Icons.person_pin_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '대표자명을 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Phone Number
                        _buildTextField(
                          label: '전화번호',
                          controller: _phoneNumberController,
                          hint: '010-1234-5678',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '전화번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Address
                        _buildTextField(
                          label: '주소',
                          controller: _addressController,
                          hint: '주소를 입력하세요',
                          icon: Icons.location_on_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '주소를 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        // Error message
                        if (authProvider.state == AuthState.error)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                            child: Text(
                              authProvider.errorMessage ?? '회원가입 실패',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Sign Up button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: authProvider.state == AuthState.loading
                                ? null
                                : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F61),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFFFF6F61).withOpacity(0.3),
                              disabledBackgroundColor: const Color(0xFFFF6F61).withOpacity(0.6),
                            ),
                            child: authProvider.state == AuthState.loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.24,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login link
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '이미 계정이 있으신가요? ',
                                style: TextStyle(
                                  color: Color(0xFFA9B4C2),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  '로그인',
                                  style: TextStyle(
                                    color: Color(0xFF06D6A0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3D405B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFA9B4C2),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFFA9B4C2),
                size: 24,
              ),
              suffixIcon: suffixIcon,
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
            validator: validator,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
