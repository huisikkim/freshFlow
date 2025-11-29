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
    // Dark theme colors
    const backgroundColor = Color(0xFF1C1C1E);
    const textColor = Color(0xFFE5E5E7);
    const labelColor = Color(0xFF98989D);
    const inputBgColor = Color(0xFF2C2C2E);
    const inputBorderColor = Color(0xFF3A3A3C);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.state == AuthState.authenticated) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          final chatProvider = context.read<ChatProvider>();
                          final accessToken = authProvider.user?.accessToken;
                          if (accessToken != null) {
                            try {
                              await chatProvider.connectWebSocket(accessToken);
                            } catch (e) {
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
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 40),
                              
                              // Logo and Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(36, 36),
                                    painter: _LeafLogoPainter(),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'FreshFlow',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 60),
                              
                              // Email/Username label
                              Text(
                                'Email / Username',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: labelColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Username field
                              TextFormField(
                                controller: _usernameController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email or username',
                                  hintStyle: TextStyle(
                                    color: labelColor.withOpacity(0.6),
                                    fontSize: 15,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: labelColor,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: inputBgColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: inputBorderColor,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: inputBorderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFC9A461),
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
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Password label
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: labelColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(
                                    color: labelColor.withOpacity(0.6),
                                    fontSize: 15,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: labelColor,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: labelColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: inputBgColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: inputBorderColor,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: inputBorderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFC9A461),
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
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              
                              // Forgot password
                              Align(
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
                                      color: Color(0xFFC9A461),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Error message
                              if (authProvider.state == AuthState.error)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
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
                              ElevatedButton(
                                onPressed: authProvider.state == AuthState.loading
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC9A461),
                                  foregroundColor: const Color(0xFF1C1C1E),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  elevation: 0,
                                  shadowColor: const Color(0xFFC9A461).withOpacity(0.3),
                                  disabledBackgroundColor: const Color(0xFFC9A461).withOpacity(0.6),
                                ),
                                child: authProvider.state == AuthState.loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1C1C1E)),
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Sign up link at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New here? ',
                    style: TextStyle(
                      color: labelColor,
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
                        color: Color(0xFFC9A461),
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
  }
}


// Custom Cherry Logo Painter
class _LeafLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw two cherries
    final cherryPaint = Paint()
      ..color = const Color(0xFFC9A461)
      ..style = PaintingStyle.fill;
    
    // Left cherry
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.65),
      size.width * 0.28,
      cherryPaint,
    );
    
    // Right cherry (slightly lower)
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.7),
      size.width * 0.28,
      cherryPaint,
    );
    
    // Stems
    final stemPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    // Left stem
    final leftStem = Path();
    leftStem.moveTo(size.width * 0.35, size.height * 0.4);
    leftStem.quadraticBezierTo(
      size.width * 0.3, size.height * 0.25,
      size.width * 0.4, size.height * 0.1,
    );
    canvas.drawPath(leftStem, stemPaint);
    
    // Right stem
    final rightStem = Path();
    rightStem.moveTo(size.width * 0.65, size.height * 0.45);
    rightStem.quadraticBezierTo(
      size.width * 0.7, size.height * 0.25,
      size.width * 0.4, size.height * 0.1,
    );
    canvas.drawPath(rightStem, stemPaint);
    
    // Small leaf on stem
    final leafPaint = Paint()
      ..color = const Color(0xFF9BAF88)
      ..style = PaintingStyle.fill;
    
    final leafPath = Path();
    leafPath.moveTo(size.width * 0.4, size.height * 0.1);
    leafPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.08,
      size.width * 0.55, size.height * 0.15,
    );
    leafPath.quadraticBezierTo(
      size.width * 0.48, size.height * 0.18,
      size.width * 0.4, size.height * 0.1,
    );
    canvas.drawPath(leafPath, leafPaint);
    
    // Highlights on cherries
    final highlightPaint = Paint()
      ..color = const Color(0xFFE5D4A3).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.58),
      size.width * 0.1,
      highlightPaint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.63),
      size.width * 0.1,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
