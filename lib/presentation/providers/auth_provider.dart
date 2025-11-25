import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/user.dart';
import 'package:fresh_flow/domain/usecases/login_usecase.dart';
import 'package:fresh_flow/domain/usecases/signup_usecase.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error, signUpSuccess }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  String? _successMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  AuthProvider({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.authRepository,
  }) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn) {
      _user = await authRepository.getCurrentUser();
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _user = await loginUseCase.execute(username, password);
      _state = AuthState.authenticated;
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String username,
    required String password,
    required String email,
    required String userType,
    required String businessNumber,
    required String businessName,
    required String ownerName,
    required String phoneNumber,
    required String address,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await signUpUseCase.execute(
        username: username,
        password: password,
        email: email,
        userType: userType,
        businessNumber: businessNumber,
        businessName: businessName,
        ownerName: ownerName,
        phoneNumber: phoneNumber,
        address: address,
      );
      _successMessage = result;
      _state = AuthState.signUpSuccess;
      notifyListeners();
      
      // Auto login after successful signup
      await login(username, password);
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
