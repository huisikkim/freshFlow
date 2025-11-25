import 'package:fresh_flow/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<String> execute({
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
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      throw Exception('모든 필드를 입력해주세요');
    }
    
    if (!email.contains('@')) {
      throw Exception('올바른 이메일 주소를 입력해주세요');
    }
    
    if (password.length < 6) {
      throw Exception('비밀번호는 최소 6자 이상이어야 합니다');
    }

    if (businessNumber.isEmpty || businessName.isEmpty || ownerName.isEmpty || 
        phoneNumber.isEmpty || address.isEmpty) {
      throw Exception('사업자 정보를 모두 입력해주세요');
    }
    
    return await repository.signUp(
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
  }
}
