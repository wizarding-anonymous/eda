import 'package:injectable/injectable.dart';

import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class LoginWithEmailUseCase {
  final AuthRepository _authRepository;

  LoginWithEmailUseCase(this._authRepository);

  Future<ApiResult<AuthResult>> execute(String email, String password) async {
    return await _authRepository.loginWithEmail(email, password);
  }
}