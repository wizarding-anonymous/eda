import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/core/di/injection.dart';
import 'package:restaurant_booking_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_booking_app/domain/repositories/venue_repository.dart';
import 'package:restaurant_booking_app/domain/repositories/booking_repository.dart';
import 'package:restaurant_booking_app/domain/repositories/payment_repository.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_phone_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_email_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_social_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/logout_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:restaurant_booking_app/domain/services/auth_service.dart';
import 'package:restaurant_booking_app/domain/usecases/venues/search_venues_usecase.dart';
import 'package:restaurant_booking_app/domain/usecases/booking/create_reservation_usecase.dart';

void main() {
  group('Infrastructure Setup Tests', () {
    setUpAll(() async {
      await configureDependencies();
    });

    test('should register all repositories', () {
      expect(getIt.isRegistered<AuthRepository>(), isTrue);
      expect(getIt.isRegistered<VenueRepository>(), isTrue);
      expect(getIt.isRegistered<BookingRepository>(), isTrue);
      expect(getIt.isRegistered<PaymentRepository>(), isTrue);
    });

    test('should register all auth use cases', () {
      expect(getIt.isRegistered<LoginWithPhoneUseCase>(), isTrue);
      expect(getIt.isRegistered<LoginWithEmailUseCase>(), isTrue);
      expect(getIt.isRegistered<LoginWithSocialUseCase>(), isTrue);
      expect(getIt.isRegistered<LogoutUseCase>(), isTrue);
      expect(getIt.isRegistered<RefreshTokenUseCase>(), isTrue);
      expect(getIt.isRegistered<GetCurrentUserUseCase>(), isTrue);
    });

    test('should register all other use cases', () {
      expect(getIt.isRegistered<SearchVenuesUseCase>(), isTrue);
      expect(getIt.isRegistered<CreateReservationUseCase>(), isTrue);
    });

    test('should register auth service', () {
      expect(getIt.isRegistered<AuthService>(), isTrue);
    });

    test('should resolve dependencies correctly', () {
      final authRepo = getIt<AuthRepository>();
      final venueRepo = getIt<VenueRepository>();
      final bookingRepo = getIt<BookingRepository>();
      final paymentRepo = getIt<PaymentRepository>();

      expect(authRepo, isNotNull);
      expect(venueRepo, isNotNull);
      expect(bookingRepo, isNotNull);
      expect(paymentRepo, isNotNull);
    });

    test('should resolve auth use cases correctly', () {
      final loginWithPhoneUseCase = getIt<LoginWithPhoneUseCase>();
      final loginWithEmailUseCase = getIt<LoginWithEmailUseCase>();
      final loginWithSocialUseCase = getIt<LoginWithSocialUseCase>();
      final logoutUseCase = getIt<LogoutUseCase>();
      final refreshTokenUseCase = getIt<RefreshTokenUseCase>();
      final getCurrentUserUseCase = getIt<GetCurrentUserUseCase>();

      expect(loginWithPhoneUseCase, isNotNull);
      expect(loginWithEmailUseCase, isNotNull);
      expect(loginWithSocialUseCase, isNotNull);
      expect(logoutUseCase, isNotNull);
      expect(refreshTokenUseCase, isNotNull);
      expect(getCurrentUserUseCase, isNotNull);
    });

    test('should resolve other use cases correctly', () {
      final searchUseCase = getIt<SearchVenuesUseCase>();
      final reservationUseCase = getIt<CreateReservationUseCase>();

      expect(searchUseCase, isNotNull);
      expect(reservationUseCase, isNotNull);
    });

    test('should resolve auth service correctly', () {
      final authService = getIt<AuthService>();
      expect(authService, isNotNull);
    });
  });
}