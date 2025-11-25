import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_flow/data/datasources/auth_local_datasource.dart';
import 'package:fresh_flow/data/datasources/auth_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/store_remote_datasource.dart';
import 'package:fresh_flow/data/repositories/auth_repository_impl.dart';
import 'package:fresh_flow/data/repositories/store_repository_impl.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/domain/repositories/store_repository.dart';
import 'package:fresh_flow/domain/usecases/login_usecase.dart';
import 'package:fresh_flow/domain/usecases/signup_usecase.dart';
import 'package:fresh_flow/domain/usecases/register_store_usecase.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/providers/store_provider.dart';

class InjectionContainer {
  static late SharedPreferences _sharedPreferences;
  static late http.Client _httpClient;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthLocalDataSource _authLocalDataSource;
  static late StoreRemoteDataSource _storeRemoteDataSource;
  static late AuthRepository _authRepository;
  static late StoreRepository _storeRepository;
  static late LoginUseCase _loginUseCase;
  static late SignUpUseCase _signUpUseCase;
  static late RegisterStoreUseCase _registerStoreUseCase;

  static Future<void> init() async {
    // External
    _sharedPreferences = await SharedPreferences.getInstance();
    _httpClient = http.Client();

    // Data sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(_httpClient);
    _authLocalDataSource = AuthLocalDataSourceImpl(_sharedPreferences);
    _storeRemoteDataSource = StoreRemoteDataSourceImpl(_httpClient);

    // Repository
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
    _storeRepository = StoreRepositoryImpl(
      remoteDataSource: _storeRemoteDataSource,
      authRepository: _authRepository,
    );

    // Use cases
    _loginUseCase = LoginUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
    _registerStoreUseCase = RegisterStoreUseCase(_storeRepository);
  }

  static AuthProvider getAuthProvider() {
    return AuthProvider(
      loginUseCase: _loginUseCase,
      signUpUseCase: _signUpUseCase,
      authRepository: _authRepository,
    );
  }

  static StoreProvider getStoreProvider() {
    return StoreProvider(
      registerStoreUseCase: _registerStoreUseCase,
    );
  }
}
