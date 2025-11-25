import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/user.dart';
import 'package:fresh_flow/domain/usecases/login_usecase.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthProvider({
    required this.loginUseCase,
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

  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
