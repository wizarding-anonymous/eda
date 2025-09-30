import 'package:injectable/injectable.dart';

import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';
import '../../services/social_auth_service.dart';
import '../../../core/network/api_result.dart';

@injectable
class LoginWithSocialUseCase {
  final AuthRepository _authRepository;
  final SocialAuthService _socialAuthService;

  LoginWithSocialUseCase(this._authRepository, this._socialAuthService);

  Future<ApiResult<AuthResult>> call(SocialProvider provider) async {
    // First, authenticate with the social provider
    final socialAuthResult =
        await _socialAuthService.authenticateWithProvider(provider);

    return await socialAuthResult.when(
      success: (socialAuthRequest) async {
        // Then, login with our backend using the social auth data
        return await _authRepository.loginWithSocial(socialAuthRequest);
      },
      failure: (failure) async => ApiResult.failure(failure),
    );
  }
}
