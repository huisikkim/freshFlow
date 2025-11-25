import 'package:fresh_flow/domain/entities/user.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception('사용자명과 비밀번호를 입력해주세요');
    }
    return await repository.login(username, password);
  }
}
