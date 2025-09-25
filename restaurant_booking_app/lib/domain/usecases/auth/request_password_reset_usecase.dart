import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class RequestPasswordResetUseCase {
  final AuthRepository _authRepository;

  RequestPasswordResetUseCase(this._authRepository);

  Future<ApiResult<void>> execute(String email) async {
    return await _authRepository.requestPasswordReset(email);
  }
}