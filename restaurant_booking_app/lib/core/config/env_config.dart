/// Environment configuration for the application
class EnvConfig {
  // Yandex Maps API Key
  static const String yandexMapsApiKey = String.fromEnvironment(
    'YANDEX_MAPS_API_KEY',
    defaultValue: 'YOUR_YANDEX_MAPS_API_KEY',
  );

  // API Base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.restaurant-booking.com',
  );

  // Debug mode
  static const bool isDebugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );

  // Environment type
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Check if we're in production environment
  static bool get isProduction => environment == 'production';

  /// Check if we're in development environment
  static bool get isDevelopment => environment == 'development';

  /// Check if API key is properly configured
  static bool get hasValidYandexMapsApiKey =>
      yandexMapsApiKey != 'YOUR_YANDEX_MAPS_API_KEY' &&
      yandexMapsApiKey.isNotEmpty;
}
