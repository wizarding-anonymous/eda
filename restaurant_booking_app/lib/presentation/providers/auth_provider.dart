import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/mock_injection.dart';
import '../../domain/entities/auth.dart';
import '../../domain/usecases/auth/login_with_phone_usecase.dart';
import '../../domain/usecases/auth/login_with_email_usecase.dart';
import '../../domain/usecases/auth/login_with_social_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/entities/user.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginWithPhoneUseCase _loginWithPhoneUseCase;
  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final LoginWithSocialUseCase _loginWithSocialUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier()
      : _loginWithPhoneUseCase = getIt<LoginWithPhoneUseCase>(),
        _loginWithEmailUseCase = getIt<LoginWithEmailUseCase>(),
        _loginWithSocialUseCase = getIt<LoginWithSocialUseCase>(),
        _logoutUseCase = getIt<LogoutUseCase>(),
        _refreshTokenUseCase = getIt<RefreshTokenUseCase>(),
        _getCurrentUserUseCase = getIt<GetCurrentUserUseCase>(),
        super(const AuthState.initial());

  /// Initialize auth state by checking for existing user session
  Future<void> initialize() async {
    state = const AuthState.loading();

    final result = await _getCurrentUserUseCase.execute();

    result.when(
      success: (user) {
        if (user != null) {
          state = AuthState.authenticated(
            user: user,
            token: '', // Token will be loaded from local storage
          );
        } else {
          state = const AuthState.unauthenticated();
        }
      },
      failure: (failure) {
        state = const AuthState.unauthenticated();
      },
    );
  }

  /// Send SMS code to phone number
  Future<bool> sendSmsCode(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginWithPhoneUseCase.sendSmsCode(phone);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Verify OTP code and complete phone login
  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginWithPhoneUseCase.verifyOtp(phone, code);

    return result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          state = AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          );
          return true;
        } else {
          state = AuthState.error(
            errorMessage: authResult.errorMessage ?? 'Неизвестная ошибка',
          );
          return false;
        }
      },
      failure: (failure) {
        state = AuthState.error(errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Login with email and password
  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginWithEmailUseCase.execute(email, password);

    return result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          state = AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          );
          return true;
        } else {
          state = AuthState.error(
            errorMessage: authResult.errorMessage ?? 'Неизвестная ошибка',
          );
          return false;
        }
      },
      failure: (failure) {
        state = AuthState.error(errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Login with social provider
  Future<bool> loginWithSocial(SocialProvider provider) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginWithSocialUseCase.call(provider);

    return result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          state = AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          );
          return true;
        } else {
          state = AuthState.error(
            errorMessage: authResult.errorMessage ?? 'Неизвестная ошибка',
          );
          return false;
        }
      },
      failure: (failure) {
        state = AuthState.error(errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Set authenticated state (used by social auth provider)
  void setAuthenticatedState(User user, String token, String refreshToken) {
    state = AuthState.authenticated(
      user: user,
      token: token,
      refreshToken: refreshToken,
    );
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    if (state.refreshToken == null) return false;

    final result = await _refreshTokenUseCase.execute(state.refreshToken!);

    return result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          state = AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          );
          return true;
        }
        return false;
      },
      failure: (failure) {
        // Token refresh failed, logout user
        logout();
        return false;
      },
    );
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    await _logoutUseCase.execute();

    state = const AuthState.unauthenticated();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
