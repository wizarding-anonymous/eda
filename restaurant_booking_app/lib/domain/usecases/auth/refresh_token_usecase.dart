import 'package:injectable/injectable.dart';

import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class RefreshTokenUseCase {
  final AuthRepository _authRepository;

  RefreshTokenUseCase(this._authRepository);

  Future<ApiResult<AuthResult>> execute(String refreshToken) async {
    return await _authRepository.refreshToken(refreshToken);
  }
}