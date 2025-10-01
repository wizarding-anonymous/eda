import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'injection.config.dart';
import '../constants/app_constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/map_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection first
  getIt.init();

  // Initialize LocalStorage after DI setup
  final localStorage = getIt<LocalStorage>();
  await localStorage.init();

  // Register additional services
  getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  getIt.registerLazySingleton<MapService>(() => MapServiceImpl());

  // Register API client
  getIt.registerSingleton<ApiClient>(ApiClient(getIt<Dio>()));
}

@module
abstract class RegisterModule {
  @singleton
  Dio get dio {
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
}
