import 'package:injectable/injectable.dart';

import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class LoginWithSocialUseCase {
  final AuthRepository _authRepository;

  LoginWithSocialUseCase(this._authRepository);

  Future<ApiResult<AuthResult>> execute(String token, SocialProvider provider) async {
    return await _authRepository.loginWithSocial(token, provider);
  }
}