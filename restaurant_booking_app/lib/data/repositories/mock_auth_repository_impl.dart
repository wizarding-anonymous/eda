import 'package:injectable/injectable.dart';

import '../../domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/network/api_result.dart';
import '../../core/error/failures.dart';
import '../datasources/local/local_storage.dart';

@Singleton(as: AuthRepository)
class MockAuthRepositoryImpl implements AuthRepository {
  final LocalStorage _localStorage;

  MockAuthRepositoryImpl(this._localStorage);

  // Предустановленные пользователи для тестирования
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    'test@example.com': {
      'id': '1',
      'email': 'test@example.com',
      'password': '123456',
      'name': 'Тест Пользователь',
      'phone': '+7 (999) 123-45-67',
      'avatar_url': null,
      'rating': 4.5,
      'preferences': {
        'language': 'ru',
        'theme': 'system',
        'notifications': {
          'push_enabled': true,
          'sms_enabled': true,
          'email_enabled': true,
          'marketing_enabled': false,
        },
        'default_city': 'Москва',
      },
      'linked_accounts': [],
      'created_at': '2024-01-01T00:00:00Z',
    },
    'admin@restaurant.com': {
      'id': '2',
      'email': 'admin@restaurant.com',
      'password': 'admin123',
      'name': 'Админ Ресторанов',
      'phone': '+7 (999) 987-65-43',
      'avatar_url': null,
      'rating': 5.0,
      'preferences': {
        'language': 'ru',
        'theme': 'light',
        'notifications': {
          'push_enabled': true,
          'sms_enabled': true,
          'email_enabled': true,
          'marketing_enabled': true,
        },
        'default_city': 'Санкт-Петербург',
      },
      'linked_accounts': [],
      'created_at': '2024-01-01T00:00:00Z',
    },
  };

  @override
  Future<ApiResult<void>> sendSmsCode(String phone) async {
    // Имитируем отправку SMS
    await Future.delayed(const Duration(seconds: 1));
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<AuthResult>> verifyOtp(String phone, String code) async {
    await Future.delayed(const Duration(seconds: 1));

    // Принимаем любой код для тестирования
    if (code.length == 4) {
      final mockUserData = Map<String, dynamic>.from(_mockUsers.values.first);
      mockUserData.remove('password'); // Убираем пароль из данных пользователя

      // Отладочная информация
      print('Mock user data: $mockUserData');
      print('Name field: ${mockUserData['name']}');

      final authResult = AuthResult.success(
        user: User.fromJson(mockUserData),
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Сохраняем токены и данные пользователя
      await _localStorage.saveAuthToken(authResult.accessToken);
      await _localStorage.saveRefreshToken(authResult.refreshToken);
      await _localStorage.saveUserData(mockUserData);

      return ApiResult.success(authResult);
    }

    return const ApiResult.failure(
      ServerFailure('Неверный код подтверждения'),
    );
  }

  @override
  Future<ApiResult<AuthResult>> loginWithEmail(
      String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final mockUser = _mockUsers[email.toLowerCase()];

    if (mockUser != null && mockUser['password'] == password) {
      final mockUserData = Map<String, dynamic>.from(mockUser);
      mockUserData.remove('password'); // Убираем пароль из данных пользователя

      final authResult = AuthResult.success(
        user: User.fromJson(mockUserData),
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Сохраняем токены и данные пользователя
      await _localStorage.saveAuthToken(authResult.accessToken);
      await _localStorage.saveRefreshToken(authResult.refreshToken);
      await _localStorage.saveUserData(mockUserData);

      return ApiResult.success(authResult);
    }

    return const ApiResult.failure(
      ServerFailure('Неверный email или пароль'),
    );
  }

  @override
  Future<ApiResult<AuthResult>> loginWithSocial(
      SocialAuthRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    // Для тестирования всегда возвращаем успешный результат
    final mockUserData = Map<String, dynamic>.from(_mockUsers.values.first);
    mockUserData.remove('password'); // Убираем пароль из данных пользователя

    final authResult = AuthResult.success(
      user: User.fromJson(mockUserData),
      accessToken: 'mock_social_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_social_refresh_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _localStorage.saveAuthToken(authResult.accessToken);
    await _localStorage.saveRefreshToken(authResult.refreshToken);
    await _localStorage.saveUserData(mockUserData);

    return ApiResult.success(authResult);
  }

  @override
  Future<ApiResult<LinkedAccount>> linkSocialAccount(
      AccountLinkRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final linkedAccount = LinkedAccount(
      id: 'mock_linked_${DateTime.now().millisecondsSinceEpoch}',
      provider: request.provider,
      socialId: 'mock_social_id_${DateTime.now().millisecondsSinceEpoch}',
      socialUsername: 'mock_user',
      socialEmail: 'linked@example.com',
      linkedAt: DateTime.now(),
    );

    return ApiResult.success(linkedAccount);
  }

  @override
  Future<ApiResult<void>> unlinkSocialAccount(String linkedAccountId) async {
    await Future.delayed(const Duration(seconds: 1));
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<List<LinkedAccount>>> getLinkedAccounts() async {
    await Future.delayed(const Duration(seconds: 1));
    return const ApiResult.success([]);
  }

  @override
  Future<ApiResult<AuthResult>> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(seconds: 1));

    final userData = _localStorage.getUserData();
    if (userData != null) {
      final authResult = AuthResult.success(
        user: User.fromJson(userData),
        accessToken:
            'mock_refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_new_refresh_${DateTime.now().millisecondsSinceEpoch}',
      );

      await _localStorage.saveAuthToken(authResult.accessToken);
      await _localStorage.saveRefreshToken(authResult.refreshToken);

      return ApiResult.success(authResult);
    }

    return const ApiResult.failure(
      ServerFailure('Недействительный refresh token'),
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
        return const ApiResult.failure(
          CacheFailure('Failed to parse user data'),
        );
      }
    }

    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<User>> updateProfile(User user) async {
    await Future.delayed(const Duration(seconds: 1));

    final updatedUserData = user.toJson();
    updatedUserData['updatedAt'] = DateTime.now().toIso8601String();

    await _localStorage.saveUserData(updatedUserData);

    return ApiResult.success(User.fromJson(updatedUserData));
  }

  @override
  Future<ApiResult<void>> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    await _localStorage.clearAll();
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUsers.containsKey(email.toLowerCase())) {
      return const ApiResult.success(null);
    }

    return const ApiResult.failure(
      ServerFailure('Пользователь с таким email не найден'),
    );
  }

  @override
  Future<ApiResult<void>> resetPassword(
      String token, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));

    // Для тестирования всегда успешно
    return const ApiResult.success(null);
  }

  /// Получить список доступных тестовых пользователей
  static List<Map<String, String>> getTestUsers() {
    return _mockUsers.entries.map((entry) {
      final userData = entry.value;
      return {
        'email': entry.key,
        'password': userData['password'] as String,
        'name': userData['name'] as String,
      };
    }).toList();
  }
}
