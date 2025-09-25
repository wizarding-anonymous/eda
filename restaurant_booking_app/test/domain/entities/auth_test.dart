import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/entities/user.dart';

void main() {
  group('AuthState', () {
    test('should create initial state correctly', () {
      const authState = AuthState.initial();
      
      expect(authState.user, isNull);
      expect(authState.isAuthenticated, isFalse);
      expect(authState.token, isNull);
      expect(authState.refreshToken, isNull);
      expect(authState.isLoading, isFalse);
      expect(authState.errorMessage, isNull);
      expect(authState.status, AuthStatus.initial);
    });

    test('should create loading state correctly', () {
      const authState = AuthState.loading();
      
      expect(authState.isLoading, isTrue);
      expect(authState.status, AuthStatus.loading);
      expect(authState.isAuthenticated, isFalse);
    });

    test('should create authenticated state correctly', () {
      final user = User(
        id: '1',
        name: 'Test User',
        rating: 4.5,
        preferences: const UserPreferences(
          language: 'ru',
          theme: ThemeMode.system,
          notifications: NotificationSettings(
            pushEnabled: true,
            smsEnabled: true,
            emailEnabled: true,
            marketingEnabled: false,
          ),
        ),
        createdAt: DateTime.now(),
      );

      final authState = AuthState.authenticated(
        user: user,
        token: 'access_token',
        refreshToken: 'refresh_token',
      );
      
      expect(authState.user, equals(user));
      expect(authState.isAuthenticated, isTrue);
      expect(authState.token, equals('access_token'));
      expect(authState.refreshToken, equals('refresh_token'));
      expect(authState.isLoading, isFalse);
      expect(authState.status, AuthStatus.authenticated);
    });

    test('should create unauthenticated state correctly', () {
      const authState = AuthState.unauthenticated(
        errorMessage: 'Invalid credentials',
      );
      
      expect(authState.user, isNull);
      expect(authState.isAuthenticated, isFalse);
      expect(authState.errorMessage, equals('Invalid credentials'));
      expect(authState.status, AuthStatus.unauthenticated);
    });

    test('should create error state correctly', () {
      const authState = AuthState.error(
        errorMessage: 'Network error',
      );
      
      expect(authState.errorMessage, equals('Network error'));
      expect(authState.status, AuthStatus.error);
      expect(authState.isAuthenticated, isFalse);
    });

    test('should copy with new values correctly', () {
      const initialState = AuthState.initial();
      
      final newState = initialState.copyWith(
        isLoading: true,
        errorMessage: 'Test error',
      );
      
      expect(newState.isLoading, isTrue);
      expect(newState.errorMessage, equals('Test error'));
      expect(newState.user, equals(initialState.user));
      expect(newState.isAuthenticated, equals(initialState.isAuthenticated));
    });
  });

  group('AuthResult', () {
    test('should create success result correctly', () {
      final user = User(
        id: '1',
        name: 'Test User',
        rating: 4.5,
        preferences: const UserPreferences(
          language: 'ru',
          theme: ThemeMode.system,
          notifications: NotificationSettings(
            pushEnabled: true,
            smsEnabled: true,
            emailEnabled: true,
            marketingEnabled: false,
          ),
        ),
        createdAt: DateTime.now(),
      );

      final authResult = AuthResult.success(
        user: user,
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );
      
      expect(authResult.isSuccess, isTrue);
      expect(authResult.user, equals(user));
      expect(authResult.accessToken, equals('access_token'));
      expect(authResult.refreshToken, equals('refresh_token'));
      expect(authResult.errorMessage, isNull);
    });

    test('should create failure result correctly', () {
      const authResult = AuthResult.failure(
        errorMessage: 'Invalid credentials',
      );
      
      expect(authResult.isSuccess, isFalse);
      expect(authResult.user, isNull);
      expect(authResult.accessToken, isEmpty);
      expect(authResult.refreshToken, isEmpty);
      expect(authResult.errorMessage, equals('Invalid credentials'));
    });

    test('should serialize to JSON correctly', () {
      final user = User(
        id: '1',
        name: 'Test User',
        rating: 4.5,
        preferences: const UserPreferences(
          language: 'ru',
          theme: ThemeMode.system,
          notifications: NotificationSettings(
            pushEnabled: true,
            smsEnabled: true,
            emailEnabled: true,
            marketingEnabled: false,
          ),
        ),
        createdAt: DateTime.now(),
      );

      final authResult = AuthResult.success(
        user: user,
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );
      
      final json = authResult.toJson();
      
      expect(json['user'], isNotNull);
      expect(json['access_token'], equals('access_token'));
      expect(json['refresh_token'], equals('refresh_token'));
    });
  });

  group('LoginRequest', () {
    test('should create phone login request correctly', () {
      const loginRequest = LoginRequest.phone(
        phone: '+79123456789',
        otpCode: '123456',
      );
      
      expect(loginRequest.identifier, equals('+79123456789'));
      expect(loginRequest.otpCode, equals('123456'));
      expect(loginRequest.password, isNull);
      expect(loginRequest.method, equals(LoginMethod.phone));
    });

    test('should create email login request correctly', () {
      const loginRequest = LoginRequest.email(
        email: 'test@example.com',
        password: 'password123',
      );
      
      expect(loginRequest.identifier, equals('test@example.com'));
      expect(loginRequest.password, equals('password123'));
      expect(loginRequest.otpCode, isNull);
      expect(loginRequest.method, equals(LoginMethod.email));
    });

    test('should create social login request correctly', () {
      const loginRequest = LoginRequest.social(
        token: 'social_token',
        provider: SocialProvider.google,
      );
      
      expect(loginRequest.identifier, equals('social_token'));
      expect(loginRequest.password, isNull);
      expect(loginRequest.otpCode, isNull);
      expect(loginRequest.method, equals(LoginMethod.social));
    });
  });
}