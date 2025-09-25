import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/entities/user.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_email_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/request_password_reset_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

import '../domain/usecases/auth/login_with_phone_usecase_test.mocks.dart';

void main() {
  group('Email Authentication Integration Tests', () {
    late MockAuthRepository mockAuthRepository;
    late LoginWithEmailUseCase loginUseCase;
    late RequestPasswordResetUseCase requestPasswordResetUseCase;
    late ResetPasswordUseCase resetPasswordUseCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      loginUseCase = LoginWithEmailUseCase(mockAuthRepository);
      requestPasswordResetUseCase = RequestPasswordResetUseCase(mockAuthRepository);
      resetPasswordUseCase = ResetPasswordUseCase(mockAuthRepository);
    });

    group('Email Login Flow', () {
      test('should complete successful email login flow', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123!';
        
        final user = User(
          id: '1',
          name: 'Test User',
          email: email,
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

        when(mockAuthRepository.loginWithEmail(email, password))
            .thenAnswer((_) async => ApiResult.success(authResult));

        // Act
        final result = await loginUseCase.execute(email, password);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.user?.email, equals(email));
        expect(result.dataOrNull?.accessToken, equals('access_token'));
        verify(mockAuthRepository.loginWithEmail(email, password));
      });

      test('should handle invalid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';
        
        const failure = ServerFailure('Invalid credentials');
        when(mockAuthRepository.loginWithEmail(email, password))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await loginUseCase.execute(email, password);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failureOrNull, equals(failure));
      });
    });

    group('Password Reset Flow', () {
      test('should complete successful password reset flow', () async {
        // Arrange
        const email = 'test@example.com';
        const resetToken = 'reset_token_123';
        const newPassword = 'NewPassword123!';

        when(mockAuthRepository.requestPasswordReset(email))
            .thenAnswer((_) async => const ApiResult.success(null));
        
        when(mockAuthRepository.resetPassword(resetToken, newPassword))
            .thenAnswer((_) async => const ApiResult.success(null));

        // Act - Request password reset
        final requestResult = await requestPasswordResetUseCase.execute(email);
        
        // Assert - Request should succeed
        expect(requestResult.isSuccess, isTrue);
        verify(mockAuthRepository.requestPasswordReset(email));

        // Act - Reset password with token
        final resetResult = await resetPasswordUseCase.execute(resetToken, newPassword);
        
        // Assert - Reset should succeed
        expect(resetResult.isSuccess, isTrue);
        verify(mockAuthRepository.resetPassword(resetToken, newPassword));
      });

      test('should handle invalid email for password reset', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const failure = ServerFailure('Email not found');
        
        when(mockAuthRepository.requestPasswordReset(email))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await requestPasswordResetUseCase.execute(email);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failureOrNull, equals(failure));
      });

      test('should handle invalid reset token', () async {
        // Arrange
        const invalidToken = 'invalid_token';
        const newPassword = 'NewPassword123!';
        const failure = ServerFailure('Invalid or expired token');
        
        when(mockAuthRepository.resetPassword(invalidToken, newPassword))
            .thenAnswer((_) async => const ApiResult.failure(failure));

        // Act
        final result = await resetPasswordUseCase.execute(invalidToken, newPassword);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.failureOrNull, equals(failure));
      });
    });

    group('Email Validation', () {
      test('should validate email format correctly', () {
        // Test cases for email validation
        const validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
        ];

        const invalidEmails = [
          'invalid-email',
          '@example.com',
          'test@',
          'test.example.com',
        ];

        for (final email in validEmails) {
          expect(
            RegExp(r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email),
            isTrue,
            reason: 'Email $email should be valid',
          );
        }

        for (final email in invalidEmails) {
          expect(
            RegExp(r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email),
            isFalse,
            reason: 'Email $email should be invalid',
          );
        }
      });
    });

    group('Password Validation', () {
      test('should validate password strength correctly', () {
        // Test cases for password validation
        const validPasswords = [
          'Password123!',
          'MySecure1',
          'Test1234',
        ];

        const invalidPasswords = [
          '123456', // Too short
          'password', // No uppercase or numbers
          'PASSWORD', // No lowercase or numbers
          'Password', // No numbers
          '12345678', // No letters
        ];

        bool isValidPassword(String password) {
          return password.length >= 8 &&
              RegExp(r'[A-Z]').hasMatch(password) &&
              RegExp(r'[a-z]').hasMatch(password) &&
              RegExp(r'\d').hasMatch(password);
        }

        for (final password in validPasswords) {
          expect(
            isValidPassword(password),
            isTrue,
            reason: 'Password $password should be valid',
          );
        }

        for (final password in invalidPasswords) {
          expect(
            isValidPassword(password),
            isFalse,
            reason: 'Password $password should be invalid',
          );
        }
      });
    });
  });
}