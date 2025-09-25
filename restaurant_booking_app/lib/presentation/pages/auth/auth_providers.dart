import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_booking_app/domain/services/auth_service.dart';
import 'package:restaurant_booking_app/data/repositories/auth_repository_impl.dart';
import 'package:restaurant_booking_app/data/datasources/remote/api_client.dart';
import 'package:restaurant_booking_app/data/datasources/local/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  // This is a temporary setup. In a real app, you would use a DI container
  // to provide the dependencies.
  final dio = Dio(BaseOptions(baseUrl: 'http://0.0.0.0:8000'));
  final apiClient = ApiClient(dio);
  final localStorage = LocalStorage(Hive.box('authBox'));
  final authRepository = AuthRepositoryImpl(apiClient, localStorage);
  return AuthServiceImpl(authRepository);
});

final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref.watch(authServiceProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  LoginNotifier(this._authService) : super(const AsyncValue.data(null));

  final AuthService _authService;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.loginWithEmail(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, AsyncValue<void>>((ref) {
  return RegisterNotifier(ref.watch(authServiceProvider));
});

class RegisterNotifier extends StateNotifier<AsyncValue<void>> {
  RegisterNotifier(this._authService) : super(const AsyncValue.data(null));

  final AuthService _authService;

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.registerWithEmail(name, email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}