import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

import 'login_with_phone_usecase_test.mocks.dart';

void main() {
  late ResetPasswordUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ResetPasswordUseCase(mockAuthRepository);
  });

  group('ResetPasswordUseCase', () {
    const testToken = 'reset_token_123';
    const testPassword = 'NewPassword123!';

    test('should reset password successfully', () async {
      // Arrange
      when(mockAuthRepository.resetPassword(testToken, testPassword))
          .thenAnswer((_) async => const ApiResult.success(null));

      // Act
      final result = await useCase.execute(testToken, testPassword);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockAuthRepository.resetPassword(testToken, testPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when password reset fails', () async {
      // Arrange
      const failure = ServerFailure('Invalid or expired token');
      when(mockAuthRepository.resetPassword(testToken, testPassword))
          .thenAnswer((_) async => const ApiResult.failure(failure));

      // Act
      final result = await useCase.execute(testToken, testPassword);

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.failure, equals(failure));
      verify(mockAuthRepository.resetPassword(testToken, testPassword));
    });
  });
}