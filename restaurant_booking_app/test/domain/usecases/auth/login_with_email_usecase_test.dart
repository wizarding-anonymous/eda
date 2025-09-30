import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/entities/user.dart';
import 'package:restaurant_booking_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_email_usecase.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

import 'login_with_phone_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  // Provide dummy values for Mockito
  provideDummy<ApiResult<AuthResult>>(
      const ApiResult.failure(ServerFailure('dummy')));
  provideDummy<ApiResult<void>>(
      const ApiResult.failure(ServerFailure('dummy')));
  provideDummy<ApiResult<User?>>(
      const ApiResult.failure(ServerFailure('dummy')));
  provideDummy<ApiResult<User>>(
      const ApiResult.failure(ServerFailure('dummy')));
  late LoginWithEmailUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginWithEmailUseCase(mockAuthRepository);
  });

  group('LoginWithEmailUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('should login with email successfully', () async {
      // Arrange
      final user = User(
        id: '1',
        name: 'Test User',
        email: testEmail,
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

      when(mockAuthRepository.loginWithEmail(testEmail, testPassword))
          .thenAnswer((_) async => ApiResult.success(authResult));

      // Act
      final result = await useCase.execute(testEmail, testPassword);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.user?.email, equals(testEmail));
      expect(result.dataOrNull?.accessToken, equals('access_token'));
      verify(mockAuthRepository.loginWithEmail(testEmail, testPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when email login fails', () async {
      // Arrange
      const failure = ServerFailure('Invalid credentials');
      when(mockAuthRepository.loginWithEmail(testEmail, testPassword))
          .thenAnswer((_) async => const ApiResult.failure(failure));

      // Act
      final result = await useCase.execute(testEmail, testPassword);

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.failureOrNull, equals(failure));
      verify(mockAuthRepository.loginWithEmail(testEmail, testPassword));
    });
  });
}
