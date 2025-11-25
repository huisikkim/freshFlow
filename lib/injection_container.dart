import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_flow/data/datasources/auth_local_datasource.dart';
import 'package:fresh_flow/data/datasources/auth_remote_datasource.dart';
import 'package:fresh_flow/data/repositories/auth_repository_impl.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/domain/usecases/login_usecase.dart';
import 'package:fresh_flow/domain/usecases/signup_usecase.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';

class InjectionContainer {
  static late SharedPreferences _sharedPreferences;
  static late http.Client _httpClient;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthLocalDataSource _authLocalDataSource;
  static late AuthRepository _authRepository;
  static late LoginUseCase _loginUseCase;
  static late SignUpUseCase _signUpUseCase;

  static Future<void> init() async {
    // External
    _sharedPreferences = await SharedPreferences.getInstance();
    _httpClient = http.Client();

    // Data sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(_httpClient);
    _authLocalDataSource = AuthLocalDataSourceImpl(_sharedPreferences);

    // Repository
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );

    // Use cases
    _loginUseCase = LoginUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
  }

  static AuthProvider getAuthProvider() {
    return AuthProvider(
      loginUseCase: _loginUseCase,
      signUpUseCase: _signUpUseCase,
      authRepository: _authRepository,
    );
  }
}
