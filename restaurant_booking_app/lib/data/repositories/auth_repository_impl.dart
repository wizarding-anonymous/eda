import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/network/api_result.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/api_client.dart';
import '../datasources/local/local_storage.dart';

@Singleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AuthRepositoryImpl(this._apiClient, this._localStorage);

  @override
  Future<ApiResult<void>> sendSmsCode(String phone) async {
    return await _apiClient.post<void>(
      '/auth/sms/request',
      data: {'phone': phone},
    );
  }

  @override
  Future<ApiResult<AuthResult>> verifyOtp(String phone, String code) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/auth/sms/verify',
      data: {'phone': phone, 'code': code},
    );

    return result.when(
      success: (data) {
        final authResult = AuthResult.fromJson(data);
        // Save tokens locally
        _localStorage.saveAuthToken(authResult.accessToken);
        _localStorage.saveRefreshToken(authResult.refreshToken);
        return ApiResult.success(authResult);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<AuthResult>> registerWithEmail(String name, String email, String password) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/users/',
      data: {'name': name, 'email': email, 'password': password},
    );

    return result.when(
      success: (data) {
        // After registration, we should log in to get the token
        return loginWithEmail(email, password);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<AuthResult>> loginWithEmail(String email, String password) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/token',
      data: {'username': email, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return result.when(
      success: (data) {
        final authResult = AuthResult.fromJson(data);
        // Save tokens locally
        _localStorage.saveAuthToken(authResult.accessToken);
        _localStorage.saveRefreshToken(authResult.refreshToken);
        return ApiResult.success(authResult);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<AuthResult>> loginWithSocial(String token, SocialProvider provider) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/auth/social',
      data: {'token': token, 'provider': provider.name},
    );

    return result.when(
      success: (data) {
        final authResult = AuthResult.fromJson(data);
        // Save tokens locally
        _localStorage.saveAuthToken(authResult.accessToken);
        _localStorage.saveRefreshToken(authResult.refreshToken);
        return ApiResult.success(authResult);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<AuthResult>> refreshToken(String refreshToken) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    return result.when(
      success: (data) {
        final authResult = AuthResult.fromJson(data);
        // Save new tokens
        _localStorage.saveAuthToken(authResult.accessToken);
        _localStorage.saveRefreshToken(authResult.refreshToken);
        return ApiResult.success(authResult);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<void>> logout() async {
    await _localStorage.clearAuthTokens();
    await _localStorage.clearUserData();
    return const ApiResult.success(null);
  }

  @override
  Stream<AuthState> get authStateChanges {
    // Create a stream controller to emit auth state changes
    return Stream.periodic(const Duration(seconds: 1), (_) {
      final token = _localStorage.getAuthToken();
      final userData = _localStorage.getUserData();
      
      if (token != null && userData != null) {
        try {
          final user = User.fromJson(userData);
          return AuthState.authenticated(
            user: user,
            token: token,
            refreshToken: _localStorage.getRefreshToken(),
          );
        } catch (e) {
          return const AuthState.unauthenticated();
        }
      }
      
      return const AuthState.unauthenticated();
    }).distinct();
  }

  @override
  Future<ApiResult<User?>> getCurrentUser() async {
    final userData = _localStorage.getUserData();
    if (userData != null) {
      try {
        final user = User.fromJson(userData);
        return ApiResult.success(user);
      } catch (e) {
        return ApiResult.failure(CacheFailure('Failed to parse user data'));
      }
    }

    // Fetch from API if not in cache
    final result = await _apiClient.get<Map<String, dynamic>>('/auth/me');
    return result.when(
      success: (data) {
        final user = User.fromJson(data);
        _localStorage.saveUserData(data);
        return ApiResult.success(user);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<User>> updateProfile(User user) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      '/auth/profile',
      data: user.toJson(),
    );

    return result.when(
      success: (data) {
        final updatedUser = User.fromJson(data);
        _localStorage.saveUserData(data);
        return ApiResult.success(updatedUser);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<void>> deleteAccount() async {
    final result = await _apiClient.delete<void>('/auth/account');
    
    return result.when(
      success: (_) async {
        await _localStorage.clearAll();
        return const ApiResult.success(null);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<void>> requestPasswordReset(String email) async {
    return await _apiClient.post<void>(
      '/auth/password/reset/request',
      data: {'email': email},
    );
  }

  @override
  Future<ApiResult<void>> resetPassword(String token, String newPassword) async {
    return await _apiClient.post<void>(
      '/auth/password/reset/confirm',
      data: {'token': token, 'password': newPassword},
    );
  }
}