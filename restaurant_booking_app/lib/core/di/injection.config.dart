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
import 'package:restaurant_booking_app/domain/services/payment_security_service.dart'
    as _i137;
import 'package:restaurant_booking_app/domain/services/payment_service.dart'
    as _i758;
import 'package:restaurant_booking_app/domain/services/preorder_payment_service.dart'
    as _i777;
import 'package:restaurant_booking_app/domain/services/social_auth_service.dart'
    as _i1070;
import 'package:restaurant_booking_app/domain/usecases/auth/get_current_user_usecase.dart'
    as _i487;
import 'package:restaurant_booking_app/domain/usecases/auth/get_linked_accounts_usecase.dart'
    as _i526;
import 'package:restaurant_booking_app/domain/usecases/auth/link_social_account_usecase.dart'
    as _i717;
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
import 'package:restaurant_booking_app/domain/usecases/auth/unlink_social_account_usecase.dart'
    as _i447;
import 'package:restaurant_booking_app/domain/usecases/booking/create_reservation_usecase.dart'
    as _i554;
import 'package:restaurant_booking_app/domain/usecases/payment/process_preorder_payment_usecase.dart'
    as _i372;
import 'package:restaurant_booking_app/domain/usecases/payment/process_qr_payment_usecase.dart'
    as _i709;
import 'package:restaurant_booking_app/domain/usecases/venues/get_categories_usecase.dart'
    as _i869;
import 'package:restaurant_booking_app/domain/usecases/venues/get_venues_by_category_usecase.dart'
    as _i861;
import 'package:restaurant_booking_app/domain/usecases/venues/search_venues_usecase.dart'
    as _i1064;
import 'package:restaurant_booking_app/presentation/providers/social_auth_provider.dart'
    as _i74;

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
    gh.factory<_i137.PaymentSecurityService>(
        () => _i137.PaymentSecurityService());
    gh.singleton<_i361.Dio>(() => registerModule.dio);
    gh.singleton<_i1071.LocalStorage>(() => _i1071.LocalStorage());
    gh.singleton<_i1070.SocialAuthService>(() => _i1070.SocialAuthService());
    gh.singleton<_i864.ApiClient>(() => _i864.ApiClient(gh<_i361.Dio>()));
    gh.singleton<_i251.BookingRepository>(
        () => _i670.BookingRepositoryImpl(gh<_i864.ApiClient>()));
    gh.singleton<_i247.VenueRepository>(
        () => _i34.VenueRepositoryImpl(gh<_i864.ApiClient>()));
    gh.singleton<_i994.PaymentRepository>(
        () => _i635.PaymentRepositoryImpl(gh<_i864.ApiClient>()));
    gh.factory<_i554.CreateReservationUseCase>(
        () => _i554.CreateReservationUseCase(gh<_i251.BookingRepository>()));
    gh.factory<_i709.ProcessQRPaymentUseCase>(
        () => _i709.ProcessQRPaymentUseCase(gh<_i994.PaymentRepository>()));
    gh.singleton<_i646.AuthRepository>(() => _i820.AuthRepositoryImpl(
          gh<_i864.ApiClient>(),
          gh<_i1071.LocalStorage>(),
        ));
    gh.singleton<_i758.PaymentService>(
        () => _i758.PaymentServiceImpl(gh<_i994.PaymentRepository>()));
    gh.factory<_i869.GetCategoriesUseCase>(
        () => _i869.GetCategoriesUseCase(gh<_i247.VenueRepository>()));
    gh.factory<_i861.GetVenuesByCategoryUseCase>(
        () => _i861.GetVenuesByCategoryUseCase(gh<_i247.VenueRepository>()));
    gh.factory<_i1064.SearchVenuesUseCase>(
        () => _i1064.SearchVenuesUseCase(gh<_i247.VenueRepository>()));
    gh.singleton<_i637.AuthService>(
        () => _i637.AuthService(gh<_i646.AuthRepository>()));
    gh.factory<_i487.GetCurrentUserUseCase>(
        () => _i487.GetCurrentUserUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i526.GetLinkedAccountsUseCase>(
        () => _i526.GetLinkedAccountsUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i159.LoginWithEmailUseCase>(
        () => _i159.LoginWithEmailUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i767.LoginWithPhoneUseCase>(
        () => _i767.LoginWithPhoneUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i706.LogoutUseCase>(
        () => _i706.LogoutUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i253.RefreshTokenUseCase>(
        () => _i253.RefreshTokenUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i436.RequestPasswordResetUseCase>(
        () => _i436.RequestPasswordResetUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i564.ResetPasswordUseCase>(
        () => _i564.ResetPasswordUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i447.UnlinkSocialAccountUseCase>(
        () => _i447.UnlinkSocialAccountUseCase(gh<_i646.AuthRepository>()));
    gh.factory<_i717.LinkSocialAccountUseCase>(
        () => _i717.LinkSocialAccountUseCase(
              gh<_i646.AuthRepository>(),
              gh<_i1070.SocialAuthService>(),
            ));
    gh.factory<_i168.LoginWithSocialUseCase>(() => _i168.LoginWithSocialUseCase(
          gh<_i646.AuthRepository>(),
          gh<_i1070.SocialAuthService>(),
        ));
    gh.factory<_i777.PreorderPaymentService>(() => _i777.PreorderPaymentService(
          gh<_i994.PaymentRepository>(),
          gh<_i251.BookingRepository>(),
        ));
    gh.factory<_i372.ProcessPreorderPaymentUseCase>(
        () => _i372.ProcessPreorderPaymentUseCase(
              gh<_i994.PaymentRepository>(),
              gh<_i251.BookingRepository>(),
            ));
    gh.factory<_i74.SocialAuthNotifier>(() => _i74.SocialAuthNotifier(
          gh<_i168.LoginWithSocialUseCase>(),
          gh<_i717.LinkSocialAccountUseCase>(),
          gh<_i447.UnlinkSocialAccountUseCase>(),
          gh<_i526.GetLinkedAccountsUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i1004.RegisterModule {}
