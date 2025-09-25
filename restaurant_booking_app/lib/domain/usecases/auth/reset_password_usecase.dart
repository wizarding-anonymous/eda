import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<ApiResult<void>> execute(String token, String newPassword) async {
    return await _authRepository.resetPassword(token, newPassword);
  }
}