import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/core/utils/validators.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/entities/user.dart';

void main() {
  group('SMS Authentication Simple Tests', () {
    group('Phone Number Validation', () {
      test('should validate Russian phone numbers correctly', () {
        // Valid Russian phone numbers
        expect(Validators.isValidPhone('+79123456789'), isTrue);
        expect(Validators.isValidPhone('89123456789'), isTrue);
        expect(Validators.isValidPhone('79123456789'), isTrue);
        expect(Validators.isValidPhone('9123456789'), isTrue);
        expect(Validators.isValidPhone('+7 (912) 345-67-89'), isTrue);
        expect(Validators.isValidPhone('8 (912) 345-67-89'), isTrue);
      });

      test('should reject invalid phone numbers', () {
        // Invalid phone numbers
        expect(Validators.isValidPhone('123'), isFalse);
        expect(Validators.isValidPhone('12345678901234'), isFalse);
        expect(Validators.isValidPhone('abcdefghij'), isFalse);
        expect(Validators.isValidPhone(''), isFalse);
        expect(Validators.isValidPhone('91234567890'), isFalse); // Wrong country code
      });

      test('should normalize phone numbers to +7 format', () {
        expect(Validators.normalizePhone('89123456789'), equals('+79123456789'));
        expect(Validators.normalizePhone('79123456789'), equals('+79123456789'));
        expect(Validators.normalizePhone('9123456789'), equals('+79123456789'));
        expect(Validators.normalizePhone('+79123456789'), equals('+79123456789'));
        expect(Validators.normalizePhone('8 (912) 345-67-89'), equals('+79123456789'));
      });

      test('should provide correct validation messages', () {
        expect(Validators.validatePhone(null), equals('Номер телефона обязателен'));
        expect(Validators.validatePhone(''), equals('Номер телефона обязателен'));
        expect(Validators.validatePhone('123'), equals('Введите корректный номер телефона'));
        expect(Validators.validatePhone('79123456789'), isNull);
      });
    });

    group('OTP Validation', () {
      test('should validate OTP codes correctly', () {
        // Valid OTP codes
        expect(Validators.isValidOTP('123456'), isTrue);
        expect(Validators.isValidOTP('000000'), isTrue);
        expect(Validators.isValidOTP('999999'), isTrue);
      });

      test('should reject invalid OTP codes', () {
        // Invalid OTP codes
        expect(Validators.isValidOTP('12345'), isFalse); // Too short
        expect(Validators.isValidOTP('1234567'), isFalse); // Too long
        expect(Validators.isValidOTP('12345a'), isFalse); // Contains letters
        expect(Validators.isValidOTP('123-45'), isFalse); // Contains special chars
        expect(Validators.isValidOTP(''), isFalse); // Empty
      });

      test('should provide correct OTP validation messages', () {
        expect(Validators.validateOTP(null), equals('Код подтверждения обязателен'));
        expect(Validators.validateOTP(''), equals('Код подтверждения обязателен'));
        expect(Validators.validateOTP('123'), equals('Код должен содержать 6 цифр'));
        expect(Validators.validateOTP('123456'), isNull);
      });
    });

    group('Auth Entities', () {
      test('should create AuthResult.success correctly', () {
        final user = User(
          id: '1',
          name: 'Test User',
          phone: '+79123456789',
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
          accessToken: 'access_token_123',
          refreshToken: 'refresh_token_456',
        );

        expect(authResult.isSuccess, isTrue);
        expect(authResult.user, equals(user));
        expect(authResult.accessToken, equals('access_token_123'));
        expect(authResult.refreshToken, equals('refresh_token_456'));
        expect(authResult.errorMessage, isNull);
      });

      test('should create AuthResult.failure correctly', () {
        const authResult = AuthResult.failure(
          errorMessage: 'Invalid OTP code',
        );

        expect(authResult.isSuccess, isFalse);
        expect(authResult.user, isNull);
        expect(authResult.accessToken, equals(''));
        expect(authResult.refreshToken, equals(''));
        expect(authResult.errorMessage, equals('Invalid OTP code'));
      });

      test('should create LoginRequest.phone correctly', () {
        const loginRequest = LoginRequest.phone(
          phone: '+79123456789',
          otpCode: '123456',
        );

        expect(loginRequest.identifier, equals('+79123456789'));
        expect(loginRequest.otpCode, equals('123456'));
        expect(loginRequest.password, isNull);
        expect(loginRequest.method, equals(LoginMethod.phone));
      });

      test('should create AuthState correctly', () {
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

        // Test initial state
        const initialState = AuthState.initial();
        expect(initialState.isAuthenticated, isFalse);
        expect(initialState.isLoading, isFalse);
        expect(initialState.user, isNull);
        expect(initialState.status, equals(AuthStatus.initial));

        // Test loading state
        const loadingState = AuthState.loading();
        expect(loadingState.isLoading, isTrue);
        expect(loadingState.status, equals(AuthStatus.loading));

        // Test authenticated state
        final authenticatedState = AuthState.authenticated(
          user: user,
          token: 'access_token',
          refreshToken: 'refresh_token',
        );
        expect(authenticatedState.isAuthenticated, isTrue);
        expect(authenticatedState.user, equals(user));
        expect(authenticatedState.token, equals('access_token'));
        expect(authenticatedState.status, equals(AuthStatus.authenticated));

        // Test error state
        const errorState = AuthState.error(errorMessage: 'Test error');
        expect(errorState.isAuthenticated, isFalse);
        expect(errorState.errorMessage, equals('Test error'));
        expect(errorState.status, equals(AuthStatus.error));
      });
    });

    group('Phone Number Format Handling', () {
      test('should handle various Russian phone formats', () {
        final testCases = [
          '+79123456789',
          '89123456789',
          '79123456789',
          '9123456789',
          '+7 (912) 345-67-89',
          '8 (912) 345-67-89',
          '7 (912) 345-67-89',
          '+7-912-345-67-89',
          '8-912-345-67-89',
        ];

        for (final phoneNumber in testCases) {
          expect(
            Validators.isValidPhone(phoneNumber),
            isTrue,
            reason: 'Phone number $phoneNumber should be valid',
          );

          final normalized = Validators.normalizePhone(phoneNumber);
          expect(
            normalized.startsWith('+7'),
            isTrue,
            reason: 'Normalized phone $normalized should start with +7',
          );
          expect(
            normalized.length,
            equals(12),
            reason: 'Normalized phone $normalized should be 12 characters',
          );
        }
      });

      test('should handle edge cases in phone normalization', () {
        // Edge cases that should return original value
        expect(Validators.normalizePhone('123'), equals('123'));
        expect(Validators.normalizePhone('invalid'), equals('invalid'));
        expect(Validators.normalizePhone(''), equals(''));
        
        // Very long numbers
        expect(Validators.normalizePhone('812345678901234'), equals('812345678901234'));
      });
    });

    group('Integration Scenarios', () {
      test('should validate complete SMS authentication flow data', () {
        // Step 1: Phone number validation and normalization
        const inputPhone = '8 (912) 345-67-89';
        expect(Validators.isValidPhone(inputPhone), isTrue);
        
        final normalizedPhone = Validators.normalizePhone(inputPhone);
        expect(normalizedPhone, equals('+79123456789'));

        // Step 2: OTP validation
        const otpCode = '123456';
        expect(Validators.isValidOTP(otpCode), isTrue);

        // Step 3: Create login request
        final loginRequest = LoginRequest.phone(
          phone: normalizedPhone,
          otpCode: otpCode,
        );
        expect(loginRequest.identifier, equals(normalizedPhone));
        expect(loginRequest.otpCode, equals(otpCode));
        expect(loginRequest.method, equals(LoginMethod.phone));

        // Step 4: Simulate successful authentication
        final user = User(
          id: 'user_123',
          name: 'John Doe',
          phone: normalizedPhone,
          rating: 4.8,
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
          accessToken: 'jwt_access_token',
          refreshToken: 'jwt_refresh_token',
        );

        expect(authResult.isSuccess, isTrue);
        expect(authResult.user?.phone, equals(normalizedPhone));

        // Step 5: Create authenticated state
        final authState = AuthState.authenticated(
          user: user,
          token: authResult.accessToken,
          refreshToken: authResult.refreshToken,
        );

        expect(authState.isAuthenticated, isTrue);
        expect(authState.user?.phone, equals(normalizedPhone));
        expect(authState.status, equals(AuthStatus.authenticated));
      });

      test('should handle error scenarios correctly', () {
        // Invalid phone number scenario
        const invalidPhone = '123';
        expect(Validators.isValidPhone(invalidPhone), isFalse);
        expect(
          Validators.validatePhone(invalidPhone),
          equals('Введите корректный номер телефона'),
        );

        // Invalid OTP scenario
        const invalidOtp = '12345';
        expect(Validators.isValidOTP(invalidOtp), isFalse);
        expect(
          Validators.validateOTP(invalidOtp),
          equals('Код должен содержать 6 цифр'),
        );

        // Authentication failure scenario
        const authResult = AuthResult.failure(
          errorMessage: 'Invalid OTP code',
        );
        expect(authResult.isSuccess, isFalse);
        expect(authResult.errorMessage, equals('Invalid OTP code'));

        // Error state
        const errorState = AuthState.error(
          errorMessage: 'Authentication failed',
        );
        expect(errorState.isAuthenticated, isFalse);
        expect(errorState.status, equals(AuthStatus.error));
        expect(errorState.errorMessage, equals('Authentication failed'));
      });
    });
  });
}