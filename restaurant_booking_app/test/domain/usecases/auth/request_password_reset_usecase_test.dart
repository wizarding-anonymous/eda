import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/request_password_reset_usecase.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

import 'login_with_phone_usecase_test.mocks.dart';

void main() {
  late RequestPasswordResetUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = RequestPasswordResetUseCase(mockAuthRepository);
  });

  group('RequestPasswordResetUseCase', () {
    const testEmail = 'test@example.com';

    test('should request password reset successfully', () async {
      // Arrange
      when(mockAuthRepository.requestPasswordReset(testEmail))
          .thenAnswer((_) async => const ApiResult.success(null));

      // Act
      final result = await useCase.execute(testEmail);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockAuthRepository.requestPasswordReset(testEmail));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when password reset request fails', () async {
      // Arrange
      const failure = ServerFailure('Email not found');
      when(mockAuthRepository.requestPasswordReset(testEmail))
          .thenAnswer((_) async => const ApiResult.failure(failure));

      // Act
      final result = await useCase.execute(testEmail);

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.failure, equals(failure));
      verify(mockAuthRepository.requestPasswordReset(testEmail));
    });
  });
}