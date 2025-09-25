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

import '../../data/datasources/local/local_storage.dart' as _i1003;
import '../../data/datasources/remote/api_client.dart' as _i1058;
import '../../data/repositories/auth_repository_impl.dart' as _i1059;
import '../../data/repositories/booking_repository_impl.dart' as _i1060;
import '../../data/repositories/payment_repository_impl.dart' as _i1061;
import '../../data/repositories/venue_repository_impl.dart' as _i1062;
import '../../domain/repositories/auth_repository.dart' as _i1063;
import '../../domain/repositories/booking_repository.dart' as _i1064;
import '../../domain/repositories/payment_repository.dart' as _i1065;
import '../../domain/repositories/venue_repository.dart' as _i1066;
import '../../domain/services/auth_service.dart' as _i1067;
import 'injection.dart' as _i1068;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main dependencies inside of GetIt
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
    gh.singleton<_i1003.LocalStorage>(() => _i1003.LocalStorage());
    gh.singleton<_i1058.ApiClient>(() => _i1058.ApiClient(
          gh<_i361.Dio>(),
          gh<_i1003.LocalStorage>(),
        ));
    gh.singleton<_i1063.AuthRepository>(() => _i1059.AuthRepositoryImpl(
          gh<_i1058.ApiClient>(),
          gh<_i1003.LocalStorage>(),
        ));
    gh.singleton<_i1064.BookingRepository>(() => _i1060.BookingRepositoryImpl(
          gh<_i1058.ApiClient>(),
        ));
    gh.singleton<_i1065.PaymentRepository>(() => _i1061.PaymentRepositoryImpl(
          gh<_i1058.ApiClient>(),
        ));
    gh.singleton<_i1066.VenueRepository>(() => _i1062.VenueRepositoryImpl(
          gh<_i1058.ApiClient>(),
        ));
    gh.singleton<_i1067.AuthService>(() => _i1067.AuthService(
          gh<_i1063.AuthRepository>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i1068.RegisterModule {}