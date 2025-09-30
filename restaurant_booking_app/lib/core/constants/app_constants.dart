import '../config/env_config.dart';

class AppConstants {
  // API
  static String get baseUrl => EnvConfig.apiBaseUrl;
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String favoritesKey = 'favorites';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPartySize = 1;
  static const int maxPartySize = 20;
  static const int otpLength = 6;

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
