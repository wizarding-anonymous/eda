import 'package:injectable/injectable.dart';

import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class GetLinkedAccountsUseCase {
  final AuthRepository _authRepository;

  GetLinkedAccountsUseCase(this._authRepository);

  Future<ApiResult<List<LinkedAccount>>> call() async {
    return await _authRepository.getLinkedAccounts();
  }
}
