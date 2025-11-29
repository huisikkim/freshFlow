import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/providers/chat_provider.dart';
import 'package:fresh_flow/presentation/pages/main_layout.dart';
import 'package:fresh_flow/presentation/pages/signup_page.dart';
import 'package:fresh_flow/presentation/pages/debug_connection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      authProvider.login(
        _usernameController.text,
        _passwordController.text,
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
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    // WebSocket 연결
                    final chatProvider = context.read<ChatProvider>();
                    final accessToken = authProvider.user?.accessToken;
                    if (accessToken != null) {
                      try {
                        await chatProvider.connectWebSocket(accessToken);
                      } catch (e) {
                        // WebSocket 연결 실패해도 로그인은 진행
                        debugPrint('WebSocket connection failed: $e');
                      }
                    }
                    
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainLayout()),
                      );
                    }
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
                        
                        // Illustration placeholder
                        Container(
                          height: 160,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6F61).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_basket_outlined,
                                    size: 48,
                                    color: Color(0xFFFF6F61),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06D6A0).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.eco_outlined,
                                    size: 48,
                                    color: Color(0xFF06D6A0),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC857).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping_outlined,
                                    size: 48,
                                    color: Color(0xFFFFC857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Email/Username label
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Email / Username',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D405B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Username field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your email or username',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA9B4C2),
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Color(0xFFA9B4C2),
                                size: 24,
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
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Password label
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D405B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Password field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA9B4C2),
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFFA9B4C2),
                                size: 24,
                              ),
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Forgot password
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF06D6A0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Error message
                        if (authProvider.state == AuthState.error)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                            child: Text(
                              authProvider.errorMessage ?? 'Login failed',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        // Login button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: authProvider.state == AuthState.loading
                                ? null
                                : _handleLogin,
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
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.24,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Sign up link
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'New here? ',
                                style: TextStyle(
                                  color: Color(0xFFA9B4C2),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Sign Up',
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
}
