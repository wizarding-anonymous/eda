import 'package:injectable/injectable.dart';

import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<ApiResult<User?>> execute() async {
    return await _authRepository.getCurrentUser();
  }
}