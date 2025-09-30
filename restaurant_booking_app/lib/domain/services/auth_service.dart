import 'dart:async';
import 'package:injectable/injectable.dart';

import '../entities/auth.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/network/api_result.dart';

/// Service that manages authentication state and provides high-level auth operations
@singleton
class AuthService {
  final AuthRepository _authRepository;

  // Stream controller for auth state changes
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  AuthState _currentState = const AuthState.initial();

  AuthService(this._authRepository) {
    // Listen to repository auth state changes
    _authRepository.authStateChanges.listen((state) {
      _currentState = state;
      _authStateController.add(state);
    });
  }

  /// Current authentication state
  AuthState get currentState => _currentState;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _currentState.isAuthenticated;

  /// Get current user if authenticated
  User? get currentUser => _currentState.user;

  /// Get current access token if authenticated
  String? get accessToken => _currentState.token;

  /// Initialize the auth service and check for existing session
  Future<void> initialize() async {
    _updateState(const AuthState.loading());

    final result = await _authRepository.getCurrentUser();

    result.when(
      success: (user) {
        if (user != null) {
          _updateState(AuthState.authenticated(
            user: user,
            token: _currentState.token ?? '',
          ));
        } else {
          _updateState(const AuthState.unauthenticated());
        }
      },
      failure: (failure) {
        _updateState(const AuthState.unauthenticated());
      },
    );
  }

  /// Send SMS verification code to phone number
  Future<ApiResult<void>> sendSmsCode(String phone) async {
    _updateState(_currentState.copyWith(isLoading: true, errorMessage: null));

    final result = await _authRepository.sendSmsCode(phone);

    result.when(
      success: (_) {
        _updateState(_currentState.copyWith(isLoading: false));
      },
      failure: (failure) {
        _updateState(_currentState.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
    );

    return result;
  }

  /// Verify OTP and complete phone authentication
  Future<ApiResult<AuthResult>> verifyOtp(String phone, String code) async {
    _updateState(_currentState.copyWith(isLoading: true, errorMessage: null));

    final result = await _authRepository.verifyOtp(phone, code);

    result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          _updateState(AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          ));
        } else {
          _updateState(AuthState.error(
            errorMessage: authResult.errorMessage ?? 'Неизвестная ошибка',
          ));
        }
      },
      failure: (failure) {
        _updateState(AuthState.error(errorMessage: failure.message));
      },
    );

    return result;
  }

  /// Login with email and password
  Future<ApiResult<AuthResult>> loginWithEmail(
      String email, String password) async {
    _updateState(_currentState.copyWith(isLoading: true, errorMessage: null));

    final result = await _authRepository.loginWithEmail(email, password);

    result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          _updateState(AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          ));
        } else {
          _updateState(AuthState.error(
            errorMessage: authResult.errorMessage ?? 'Неизвестная ошибка',
          ));
        }
      },
      failure: (failure) {
        _updateState(AuthState.error(errorMessage: failure.message));
      },
    );

    return result;
  }

  /// Login with social provider
  Future<ApiResult<AuthResult>> loginWithSocial(
      SocialAuthRequest request) async {
    _updateState(_currentState.copyWith(isLoading: true, errorMessage: null));

    final result = await _authRepository.loginWithSocial(request);

    result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          _updateState(AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          ));
        } else {
          _updateState(AuthState.error(
            errorMessage: authResult.errorMessage ?? 'Неизвестная ошибка',
          ));
        }
      },
      failure: (failure) {
        _updateState(AuthState.error(errorMessage: failure.message));
      },
    );

    return result;
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    if (_currentState.refreshToken == null) return false;

    final result =
        await _authRepository.refreshToken(_currentState.refreshToken!);

    return result.when(
      success: (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          _updateState(AuthState.authenticated(
            user: authResult.user!,
            token: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          ));
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

  /// Logout current user
  Future<void> logout() async {
    _updateState(_currentState.copyWith(isLoading: true));

    await _authRepository.logout();

    _updateState(const AuthState.unauthenticated());
  }

  /// Update user profile
  Future<ApiResult<User>> updateProfile(User user) async {
    final result = await _authRepository.updateProfile(user);

    result.when(
      success: (updatedUser) {
        _updateState(_currentState.copyWith(user: updatedUser));
      },
      failure: (failure) {
        // Handle error if needed
      },
    );

    return result;
  }

  /// Delete user account
  Future<ApiResult<void>> deleteAccount() async {
    final result = await _authRepository.deleteAccount();

    result.when(
      success: (_) {
        _updateState(const AuthState.unauthenticated());
      },
      failure: (failure) {
        // Handle error if needed
      },
    );

    return result;
  }

  /// Clear any error state
  void clearError() {
    _updateState(_currentState.copyWith(errorMessage: null));
  }

  /// Update the current auth state and notify listeners
  void _updateState(AuthState newState) {
    _currentState = newState;
    _authStateController.add(newState);
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
