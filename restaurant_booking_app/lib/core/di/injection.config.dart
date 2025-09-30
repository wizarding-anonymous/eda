// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:restaurant_booking_app/core/di/injection.dart' as _i1004;
import 'package:restaurant_booking_app/data/datasources/local/local_storage.dart'
    as _i1071;
import 'package:restaurant_booking_app/data/datasources/remote/api_client.dart'
    as _i864;
import 'package:restaurant_booking_app/data/repositories/auth_repository_impl.dart'
    as _i820;
import 'package:restaurant_booking_app/data/repositories/booking_repository_impl.dart'
    as _i670;
import 'package:restaurant_booking_app/data/repositories/payment_repository_impl.dart'
    as _i635;
import 'package:restaurant_booking_app/data/repositories/venue_repository_impl.dart'
    as _i34;
import 'package:restaurant_booking_app/domain/repositories/auth_repository.dart'
    as _i646;
import 'package:restaurant_booking_app/domain/repositories/booking_repository.dart'
    as _i251;
import 'package:restaurant_booking_app/domain/repositories/payment_repository.dart'
    as _i994;
import 'package:restaurant_booking_app/domain/repositories/venue_repository.dart'
    as _i247;
import 'package:restaurant_booking_app/domain/services/auth_service.dart'
    as _i637;
import 'package:restaurant_booking_app/domain/usecases/auth/get_current_user_usecase.dart'
    as _i487;
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_email_usecase.dart'
    as _i159;
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_phone_usecase.dart'
    as _i767;
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_social_usecase.dart'
    as _i168;
import 'package:restaurant_booking_app/domain/usecases/auth/logout_usecase.dart'
    as _i706;
import 'package:restaurant_booking_app/domain/usecases/auth/refresh_token_usecase.dart'
    as _i253;
import 'package:restaurant_booking_app/domain/usecases/auth/request_password_reset_usecase.dart'
    as _i436;
import 'package:restaurant_booking_app/domain/usecases/auth/reset_password_usecase.dart'
    as _i564;
import 'package:restaurant_booking_app/domain/usecases/booking/create_reservation_usecase.dart'
    as _i554;
import 'package:restaurant_booking_app/domain/usecases/venues/search_venues_usecase.dart'
    as _i1064;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i361.Dio>(() => registerModule.dio);
    gh.singleton<_i1071.LocalStorage>(() => _i1071.LocalStorage());
    gh.singleton<_i864.ApiClient>(() => _i864.ApiClient(
          gh<_i361.Dio>(),
          gh<_i1071.LocalStorage>(),
        ));
    gh.singleton<_i251.BookingRepository>(
        () => _i670.BookingRepositoryImpl(gh<_i864.ApiClient>()));
    gh.singleton<_i247.VenueRepository>(
        () => _i34.VenueRepositoryImpl(gh<_i864.ApiClient>()));
    gh.singleton<_i994.PaymentRepository>(
        () => _i635.PaymentRepositoryImpl(gh<_i864.ApiClient>()));
    gh.factory<_i554.CreateReservationUseCase>(
        () => _i554.CreateReservationUseCase(gh<_i251.BookingRepository>()));
    gh.singleton<_i646.AuthRepository>(() => _i820.AuthRepositoryImpl(
          gh<_i864.ApiClient>(),
          gh<_i1071.LocalStorage>(),
        ));
    gh.factory<_i1064.SearchVenuesUseCase>(
        () => _i1064.SearchVenuesUseCase(gh<_i247.VenueRepository>()));
    gh.singleton<_i637.AuthService>(
        () => _i637.AuthService(gh<_i646.AuthRepository>()));
    gh.factory<_i487.GetCurrentUserUseCase>(
        () => _i487.GetCurrentUserUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i159.LoginWithEmailUseCase>(
        () => _i159.LoginWithEmailUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i767.LoginWithPhoneUseCase>(
        () => _i767.LoginWithPhoneUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i168.LoginWithSocialUseCase>(
        () => _i168.LoginWithSocialUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i706.LogoutUseCase>(
        () => _i706.LogoutUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i253.RefreshTokenUseCase>(
        () => _i253.RefreshTokenUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i436.RequestPasswordResetUseCase>(
        () => _i436.RequestPasswordResetUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i564.ResetPasswordUseCase>(
        () => _i564.ResetPasswordUseCase(gh<_i646.AuthRepository>()));
    return this;
  }
}

class _$RegisterModule extends _i1004.RegisterModule {}
