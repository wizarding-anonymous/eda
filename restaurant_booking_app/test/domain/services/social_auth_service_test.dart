import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/services/social_auth_service.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';

void main() {
  group('SocialAuthService', () {
    late SocialAuthService socialAuthService;

    setUp(() {
      socialAuthService = SocialAuthService();
    });

    test('should support all required social providers', () {
      const supportedProviders = [
        SocialProvider.telegram,
        SocialProvider.yandex,
        SocialProvider.vk,
      ];

      for (final provider in supportedProviders) {
        expect(
          () => socialAuthService.authenticateWithProvider(provider),
          returnsNormally,
        );
      }
    });

    test('should reject unsupported social providers', () async {
      final result = await socialAuthService.authenticateWithProvider(
        SocialProvider.google,
      );

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (failure) {
          expect(failure.message, contains('не поддерживается'));
        },
      );
    });
  });
}
