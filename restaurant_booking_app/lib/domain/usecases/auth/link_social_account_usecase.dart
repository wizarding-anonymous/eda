import 'package:injectable/injectable.dart';

import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';
import '../../services/social_auth_service.dart';
import '../../../core/network/api_result.dart';

@injectable
class LinkSocialAccountUseCase {
  final AuthRepository _authRepository;
  final SocialAuthService _socialAuthService;

  LinkSocialAccountUseCase(this._authRepository, this._socialAuthService);

  Future<ApiResult<LinkedAccount>> call(SocialProvider provider) async {
    // First, authenticate with the social provider
    final socialAuthResult =
        await _socialAuthService.authenticateWithProvider(provider);

    return await socialAuthResult.when(
      success: (socialAuthRequest) async {
        // Then, link the account with our backend
        final linkRequest = AccountLinkRequest(
          provider: socialAuthRequest.provider,
          socialToken: socialAuthRequest.token,
        );
        return await _authRepository.linkSocialAccount(linkRequest);
      },
      failure: (failure) async => ApiResult.failure(failure),
    );
  }
}
