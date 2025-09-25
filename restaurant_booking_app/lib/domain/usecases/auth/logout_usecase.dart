import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<ApiResult<void>> execute() async {
    return await _authRepository.logout();
  }
}