import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant_booking_app/presentation/providers/auth_provider.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_phone_usecase.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/entities/user.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

// Mock class for testing
class MockAuthNotifier extends AuthNotifier {
  final LoginWithPhoneUseCase mockLoginWithPhoneUseCase;

  MockAuthNotifier(this.mockLoginWithPhoneUseCase) : super();

  @override
  Future<bool> sendSmsCode(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await mockLoginWithPhoneUseCase.sendSmsCode(phone);
    
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

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await mockLoginWithPhoneUseCase.verifyOtp(phone, code);
    
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
}

@GenerateMocks([LoginWithPhoneUseCase])
void main() {
  late MockAuthNotifier authNotifier;
  late MockLoginWithPhoneUseCase mockLoginWithPhoneUseCase;

  setUp(() {
    mockLoginWithPhoneUseCase = MockLoginWithPhoneUseCase();
    authNotifier = MockAuthNotifier(mockLoginWithPhoneUseCase);
  });

  group('SMS Authentication Provider Tests', () {
    const testPhone = '+79123456789';
    const testOtpCode = '123456';
    const invalidOtp = '000000';

    test('initial state should be AuthState.initial', () {
      expect(authNotifier.state, equals(const AuthState.initial()));
      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.errorMessage, isNull);
      expect(authNotifier.state.status, equals(AuthStatus.initial));
    });

    group('SMS Code Sending', () {
      test('should send SMS code successfully and update state correctly', () async {
        // Arrange
        when(mockLoginWithPhoneUseCase.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.success(null));

        // Act
        final result = await authNotifier.sendSmsCode(testPhone);

        // Assert
        expect(result, isTrue);
        expect(authNotifier.state.isLoading, isFalse);
        expect(authNotifier.state.errorMessage, isNull);
        verify(mockLoginWithPhoneUseCase.sendSmsCode(testPhone));
        verifyNoMoreInteractions(mockLoginWithPhoneUseCase);
      });

      test('should handle network error when sending SMS', () async {
        // Arrange
        const failure = NetworkFailure('Network connection failed');
        when(mockLoginWithPhoneUseCase.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.sendSmsCode(testPhone);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.isLoading, isFalse);
        expect(authNotifier.state.errorMessage, equals('Network connection failed'));
        verify(mockLoginWithPhoneUseCase.sendSmsCode(testPhone));
      });

      test('should handle server error when sending SMS', () async {
        // Arrange
        const failure = ServerFailure('SMS service temporarily unavailable');
        when(mockLoginWithPhoneUseCase.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.sendSmsCode(testPhone);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, equals('SMS service temporarily unavailable'));
        verify(mockLoginWithPhoneUseCase.sendSmsCode(testPhone));
      });

      test('should handle validation error for invalid phone format', () async {
        // Arrange
        const invalidPhone = '123';
        const failure = ValidationFailure('Invalid phone number format');
        when(mockLoginWithPhoneUseCase.sendSmsCode(invalidPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.sendSmsCode(invalidPhone);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, equals('Invalid phone number format'));
        verify(mockLoginWithPhoneUseCase.sendSmsCode(invalidPhone));
      });

      test('should handle rate limiting error', () async {
        // Arrange
        const failure = ServerFailure('Too many SMS requests. Please try again in 60 seconds.');
        when(mockLoginWithPhoneUseCase.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.sendSmsCode(testPhone);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, contains('Too many SMS requests'));
        verify(mockLoginWithPhoneUseCase.sendSmsCode(testPhone));
      });
    });

    group('OTP Verification', () {
      test('should verify OTP successfully and authenticate user', () async {
        // Arrange
        final user = User(
          id: 'user_123',
          name: 'John Doe',
          phone: testPhone,
          email: 'john@example.com',
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
          accessToken: 'jwt_access_token_123',
          refreshToken: 'jwt_refresh_token_456',
        );

        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => ApiResult.success(authResult));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result, isTrue);
        expect(authNotifier.state.isAuthenticated, isTrue);
        expect(authNotifier.state.user, equals(user));
        expect(authNotifier.state.user?.phone, equals(testPhone));
        expect(authNotifier.state.user?.name, equals('John Doe'));
        expect(authNotifier.state.token, equals('jwt_access_token_123'));
        expect(authNotifier.state.refreshToken, equals('jwt_refresh_token_456'));
        expect(authNotifier.state.status, equals(AuthStatus.authenticated));
        expect(authNotifier.state.errorMessage, isNull);
        expect(authNotifier.state.isLoading, isFalse);
        verify(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode));
        verifyNoMoreInteractions(mockLoginWithPhoneUseCase);
      });

      test('should handle invalid OTP error', () async {
        // Arrange
        const failure = ValidationFailure('Invalid OTP code. Please check and try again.');
        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, invalidOtp))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, invalidOtp);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.isAuthenticated, isFalse);
        expect(authNotifier.state.status, equals(AuthStatus.error));
        expect(authNotifier.state.errorMessage, equals('Invalid OTP code. Please check and try again.'));
        expect(authNotifier.state.user, isNull);
        expect(authNotifier.state.token, isNull);
        verify(mockLoginWithPhoneUseCase.verifyOtp(testPhone, invalidOtp));
      });

      test('should handle expired OTP error', () async {
        // Arrange
        const failure = ValidationFailure('OTP code has expired. Please request a new one.');
        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.status, equals(AuthStatus.error));
        expect(authNotifier.state.errorMessage, equals('OTP code has expired. Please request a new one.'));
        verify(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle authentication failure from server', () async {
        // Arrange
        const authResult = AuthResult.failure(
          errorMessage: 'User account is temporarily suspended',
        );

        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => ApiResult.success(authResult));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.status, equals(AuthStatus.error));
        expect(authNotifier.state.errorMessage, equals('User account is temporarily suspended'));
        expect(authNotifier.state.isAuthenticated, isFalse);
        verify(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle network error during OTP verification', () async {
        // Arrange
        const failure = NetworkFailure('Connection timeout. Please check your internet connection.');
        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, equals('Connection timeout. Please check your internet connection.'));
        expect(authNotifier.state.status, equals(AuthStatus.error));
        verify(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle too many failed attempts error', () async {
        // Arrange
        const failure = ValidationFailure('Too many failed attempts. Please request a new code.');
        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, contains('Too many failed attempts'));
        verify(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle server error during OTP verification', () async {
        // Arrange
        const failure = ServerFailure('Internal server error. Please try again later.');
        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, equals('Internal server error. Please try again later.'));
        verify(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode));
      });
    });

    group('State Management', () {
      test('should clear error message correctly', () async {
        // Arrange - set an error state first
        const failure = ValidationFailure('Test error message');
        when(mockLoginWithPhoneUseCase.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));
        
        await authNotifier.sendSmsCode(testPhone);
        expect(authNotifier.state.errorMessage, equals('Test error message'));

        // Act
        authNotifier.clearError();

        // Assert
        expect(authNotifier.state.errorMessage, isNull);
        expect(authNotifier.state.status, equals(AuthStatus.initial)); // Should remain the same
      });

      test('should maintain loading state during async operations', () async {
        // Arrange
        bool loadingStateDuringOperation = false;
        
        when(mockLoginWithPhoneUseCase.sendSmsCode(testPhone))
            .thenAnswer((_) async {
          // Capture loading state during operation
          loadingStateDuringOperation = authNotifier.state.isLoading;
          return const ApiResult.success(null);
        });

        // Act
        await authNotifier.sendSmsCode(testPhone);

        // Assert
        expect(loadingStateDuringOperation, isTrue);
        expect(authNotifier.state.isLoading, isFalse); // Should be false after completion
      });
    });

    group('Edge Cases', () {
      test('should handle empty phone number', () async {
        // Arrange
        const failure = ValidationFailure('Phone number is required');
        when(mockLoginWithPhoneUseCase.sendSmsCode(''))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.sendSmsCode('');

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, equals('Phone number is required'));
      });

      test('should handle empty OTP code', () async {
        // Arrange
        const failure = ValidationFailure('OTP code is required');
        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, ''))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, '');

        // Assert
        expect(result, isFalse);
        expect(authNotifier.state.errorMessage, equals('OTP code is required'));
      });

      test('should handle null user in successful auth result', () async {
        // Arrange
        const authResult = AuthResult.success(
          user: null,
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
        );

        when(mockLoginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => ApiResult.success(authResult));

        // Act
        final result = await authNotifier.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result, isFalse); // Should fail because user is null
        expect(authNotifier.state.status, equals(AuthStatus.error));
        expect(authNotifier.state.errorMessage, equals('Неизвестная ошибка'));
      });
    });

    group('Phone Number Format Handling', () {
      const phoneFormats = [
        '+79123456789',
        '+71234567890',
        '89123456789',
        '71234567890',
      ];

      for (final phone in phoneFormats) {
        test('should handle phone format: $phone', () async {
          // Arrange
          when(mockLoginWithPhoneUseCase.sendSmsCode(phone))
              .thenAnswer((_) async => const ApiResult.success(null));

          // Act
          final result = await authNotifier.sendSmsCode(phone);

          // Assert
          expect(result, isTrue);
          verify(mockLoginWithPhoneUseCase.sendSmsCode(phone));
        });
      }
    });
  });
}