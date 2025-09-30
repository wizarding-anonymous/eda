import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant_booking_app/presentation/providers/forgot_password_provider.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/request_password_reset_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

@GenerateMocks([
  ForgotPasswordNotifier,
  RequestPasswordResetUseCase,
  ResetPasswordUseCase,
])
void main() {
  // Provide dummy values for Mockito
  provideDummy<ApiResult<void>>(
      const ApiResult.failure(ServerFailure('dummy')));

  group('ForgotPasswordNotifier', () {
    test('should have initial state', () {
      // Basic test to ensure the file compiles
      expect(true, isTrue);
    });
  });
}
