import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/entities/user.dart';
import 'package:restaurant_booking_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_phone_usecase.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

import 'login_with_phone_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginWithPhoneUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginWithPhoneUseCase(mockAuthRepository);
  });

  group('LoginWithPhoneUseCase', () {
    const testPhone = '+79123456789';
    const testOtpCode = '123456';
    const invalidPhone = '123';
    const invalidOtp = '12345';

    group('sendSmsCode', () {
      test('should send SMS code successfully for valid phone', () async {
        // Arrange
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.success(null));

        // Act
        final result = await useCase.sendSmsCode(testPhone);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockAuthRepository.sendSmsCode(testPhone));
        verifyNoMoreInteractions(mockAuthRepository);
      });

      test('should handle network error when sending SMS', () async {
        // Arrange
        const failure = NetworkFailure('Network connection failed');
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.sendSmsCode(testPhone);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure, equals(failure));
        expect(result.failure?.message, equals('Network connection failed'));
        verify(mockAuthRepository.sendSmsCode(testPhone));
      });

      test('should handle server error when sending SMS', () async {
        // Arrange
        const failure = ServerFailure('SMS service unavailable');
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.sendSmsCode(testPhone);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure, equals(failure));
        expect(result.failure?.message, equals('SMS service unavailable'));
        verify(mockAuthRepository.sendSmsCode(testPhone));
      });

      test('should handle validation error for invalid phone', () async {
        // Arrange
        const failure = ValidationFailure('Invalid phone number format');
        when(mockAuthRepository.sendSmsCode(invalidPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.sendSmsCode(invalidPhone);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure, equals(failure));
        verify(mockAuthRepository.sendSmsCode(invalidPhone));
      });

      test('should handle rate limiting error', () async {
        // Arrange
        const failure = ServerFailure('Too many SMS requests. Please try again later.');
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.sendSmsCode(testPhone);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, contains('Too many SMS requests'));
        verify(mockAuthRepository.sendSmsCode(testPhone));
      });
    });

    group('verifyOtp', () {
      test('should verify OTP successfully and return complete user data', () async {
        // Arrange
        final user = User(
          id: '1',
          name: 'Test User',
          phone: testPhone,
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

        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => ApiResult.success(authResult));

        // Act
        final result = await useCase.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.isSuccess, isTrue);
        expect(result.data?.user, equals(user));
        expect(result.data?.user?.phone, equals(testPhone));
        expect(result.data?.accessToken, equals('access_token_123'));
        expect(result.data?.refreshToken, equals('refresh_token_456'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
        verifyNoMoreInteractions(mockAuthRepository);
      });

      test('should handle invalid OTP error', () async {
        // Arrange
        const failure = ValidationFailure('Invalid OTP code');
        when(mockAuthRepository.verifyOtp(testPhone, invalidOtp))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.verifyOtp(testPhone, invalidOtp);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure, equals(failure));
        expect(result.failure?.message, equals('Invalid OTP code'));
        verify(mockAuthRepository.verifyOtp(testPhone, invalidOtp));
      });

      test('should handle expired OTP error', () async {
        // Arrange
        const failure = ValidationFailure('OTP code has expired');
        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, equals('OTP code has expired'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle network error during OTP verification', () async {
        // Arrange
        const failure = NetworkFailure('Connection timeout');
        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, equals('Connection timeout'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle server error during OTP verification', () async {
        // Arrange
        const failure = ServerFailure('Internal server error');
        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, equals('Internal server error'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle authentication failure from server', () async {
        // Arrange
        const authResult = AuthResult.failure(
          errorMessage: 'Authentication failed - user not found',
        );

        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => ApiResult.success(authResult));

        // Act
        final result = await useCase.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.isSuccess, isFalse);
        expect(result.data?.errorMessage, equals('Authentication failed - user not found'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle too many attempts error', () async {
        // Arrange
        const failure = ValidationFailure('Too many failed attempts. Please request a new code.');
        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, contains('Too many failed attempts'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
      });
    });

    group('edge cases', () {
      test('should handle empty phone number', () async {
        // Arrange
        const failure = ValidationFailure('Phone number is required');
        when(mockAuthRepository.sendSmsCode(''))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.sendSmsCode('');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, equals('Phone number is required'));
      });

      test('should handle empty OTP code', () async {
        // Arrange
        const failure = ValidationFailure('OTP code is required');
        when(mockAuthRepository.verifyOtp(testPhone, ''))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await useCase.verifyOtp(testPhone, '');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, equals('OTP code is required'));
      });

      test('should handle null user in successful auth result', () async {
        // Arrange
        const authResult = AuthResult.success(
          user: null,
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
        );

        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => ApiResult.success(authResult));

        // Act
        final result = await useCase.verifyOtp(testPhone, testOtpCode);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.user, isNull);
        expect(result.data?.accessToken, equals('access_token'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
      });
    });

    group('phone number formats', () {
      const phoneFormats = [
        '+79123456789',
        '+71234567890',
        '89123456789',
        '71234567890',
      ];

      for (final phone in phoneFormats) {
        test('should handle phone format: $phone', () async {
          // Arrange
          when(mockAuthRepository.sendSmsCode(phone))
              .thenAnswer((_) async => const ApiResult.success(null));

          // Act
          final result = await useCase.sendSmsCode(phone);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.sendSmsCode(phone));
        });
      }
    });
  });
}