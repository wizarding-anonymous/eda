import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class UnlinkSocialAccountUseCase {
  final AuthRepository _authRepository;

  UnlinkSocialAccountUseCase(this._authRepository);

  Future<ApiResult<void>> call(String linkedAccountId) async {
    return await _authRepository.unlinkSocialAccount(linkedAccountId);
  }
}
