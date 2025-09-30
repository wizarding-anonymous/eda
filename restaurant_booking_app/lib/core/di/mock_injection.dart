import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/mock_auth_repository_impl.dart';
import '../../data/repositories/mock_venue_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/map_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/social_auth_service.dart';
import '../../domain/usecases/auth/login_with_phone_usecase.dart';
import '../../domain/usecases/auth/login_with_email_usecase.dart';
import '../../domain/usecases/auth/login_with_social_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/link_social_account_usecase.dart';
import '../../domain/usecases/auth/unlink_social_account_usecase.dart';
import '../../domain/usecases/auth/get_linked_accounts_usecase.dart';
import '../../domain/usecases/venues/search_venues_usecase.dart';
import '../../domain/usecases/venues/get_categories_usecase.dart';
import '../../domain/usecases/venues/get_venues_by_category_usecase.dart';

final getIt = GetIt.instance;

Future<void> configureMockDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Clear any existing registrations
  await getIt.reset();

  // Register Dio
  getIt.registerSingleton<Dio>(_createDio());

  // Register LocalStorage
  getIt.registerSingleton<LocalStorage>(LocalStorage());
  final localStorage = getIt<LocalStorage>();
  await localStorage.init();

  // Register ApiClient
  getIt.registerSingleton<ApiClient>(
    ApiClient(getIt<Dio>(), getIt<LocalStorage>()),
  );

  // Register Mock Auth Repository
  getIt.registerSingleton<AuthRepository>(
    MockAuthRepositoryImpl(getIt<LocalStorage>()),
  );

  // Register mock venue repository
  getIt.registerSingleton<VenueRepository>(
    MockVenueRepositoryImpl(),
  );

  getIt.registerSingleton<BookingRepository>(
    BookingRepositoryImpl(getIt<ApiClient>()),
  );

  getIt.registerSingleton<PaymentRepository>(
    PaymentRepositoryImpl(getIt<ApiClient>()),
  );

  // Register services
  getIt.registerSingleton<LocationService>(LocationServiceImpl());
  getIt.registerSingleton<MapService>(MapServiceImpl());
  getIt.registerSingleton<AuthService>(
    AuthService(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<SocialAuthService>(
    SocialAuthService(),
  );

  // Register use cases
  getIt.registerSingleton<LoginWithPhoneUseCase>(
    LoginWithPhoneUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LoginWithEmailUseCase>(
    LoginWithEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LoginWithSocialUseCase>(
    LoginWithSocialUseCase(getIt<AuthRepository>(), getIt<SocialAuthService>()),
  );
  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<RefreshTokenUseCase>(
    RefreshTokenUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LinkSocialAccountUseCase>(
    LinkSocialAccountUseCase(
        getIt<AuthRepository>(), getIt<SocialAuthService>()),
  );
  getIt.registerSingleton<UnlinkSocialAccountUseCase>(
    UnlinkSocialAccountUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetLinkedAccountsUseCase>(
    GetLinkedAccountsUseCase(getIt<AuthRepository>()),
  );

  // Register venue use cases
  getIt.registerSingleton<SearchVenuesUseCase>(
    SearchVenuesUseCase(getIt<VenueRepository>()),
  );
  getIt.registerSingleton<GetCategoriesUseCase>(
    GetCategoriesUseCase(getIt<VenueRepository>()),
  );
  getIt.registerSingleton<GetVenuesByCategoryUseCase>(
    GetVenuesByCategoryUseCase(getIt<VenueRepository>()),
  );
}

Dio _createDio() {
  final dio = Dio();
  dio.options.baseUrl = AppConstants.baseUrl;
  dio.options.connectTimeout = AppConstants.connectTimeout;
  dio.options.receiveTimeout = AppConstants.receiveTimeout;
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  return dio;
}
