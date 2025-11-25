import 'package:fresh_flow/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<String> execute(String username, String password, String email) async {
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      throw Exception('모든 필드를 입력해주세요');
    }
    
    if (!email.contains('@')) {
      throw Exception('올바른 이메일 주소를 입력해주세요');
    }
    
    if (password.length < 6) {
      throw Exception('비밀번호는 최소 6자 이상이어야 합니다');
    }
    
    return await repository.signUp(username, password, email);
  }
}
