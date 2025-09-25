import 'package:injectable/injectable.dart';

import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

@injectable
class LoginWithPhoneUseCase {
  final AuthRepository _authRepository;

  LoginWithPhoneUseCase(this._authRepository);

  Future<ApiResult<void>> sendSmsCode(String phone) async {
    return await _authRepository.sendSmsCode(phone);
  }

  Future<ApiResult<AuthResult>> verifyOtp(String phone, String code) async {
    return await _authRepository.verifyOtp(phone, code);
  }
}