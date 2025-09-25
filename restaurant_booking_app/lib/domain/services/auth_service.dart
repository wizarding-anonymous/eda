import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/repositories/auth_repository.dart';

abstract class AuthService {
  Stream<AuthState> get authStateChanges;
  Future<void> loginWithPhone(String phone);
  Future<void> verifyOTP(String phone, String code);
  Future<void> loginWithEmail(String email, String password);
  Future<void> registerWithEmail(String name, String email, String password);
  Future<void> logout();
}

class AuthServiceImpl implements AuthService {
  final AuthRepository _authRepository;

  AuthServiceImpl(this._authRepository);

  @override
  Stream<AuthState> get authStateChanges => _authRepository.authStateChanges;

  @override
  Future<void> loginWithEmail(String email, String password) async {
    final result = await _authRepository.loginWithEmail(email, password);
    result.when(
      success: (_) {},
      failure: (failure) => throw failure,
    );
  }

  @override
  Future<void> loginWithPhone(String phone) {
    // TODO: implement loginWithPhone
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<void> registerWithEmail(String name, String email, String password) async {
    final result = await _authRepository.registerWithEmail(name, email, password);
    result.when(
      success: (_) {},
      failure: (failure) => throw failure,
    );
  }

  @override
  Future<void> verifyOTP(String phone, String code) {
    // TODO: implement verifyOTP
    throw UnimplementedError();
  }
}