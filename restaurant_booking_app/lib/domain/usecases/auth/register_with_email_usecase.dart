import 'package:restaurant_booking_app/domain/repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  final AuthRepository repository;

  RegisterWithEmailUseCase(this.repository);

  Future<void> call(String name, String email, String password) {
    return repository.registerWithEmail(name, email, password);
  }
}