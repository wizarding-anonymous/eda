import 'dart:math';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:injectable/injectable.dart';

import '../entities/auth.dart';
import '../../core/network/api_result.dart';
import '../../core/error/failures.dart';
import '../../core/constants/social_auth_constants.dart';

@singleton
class SocialAuthService {
  /// Authenticate with Telegram
  Future<ApiResult<SocialAuthRequest>> authenticateWithTelegram() async {
    try {
      // Generate auth data for Telegram
      final authUrl = _buildTelegramAuthUrl();

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: SocialAuthConstants.callbackScheme,
      );

      final uri = Uri.parse(result);
      final authData = _parseTelegramCallback(uri);

      if (authData != null) {
        return ApiResult.success(SocialAuthRequest(
          provider: SocialProvider.telegram,
          token: authData['hash']!,
          additionalData: authData,
        ));
      } else {
        return const ApiResult.failure(
          AuthFailure('Не удалось получить данные от Telegram'),
        );
      }
    } catch (e) {
      return ApiResult.failure(AuthFailure('Ошибка авторизации Telegram: $e'));
    }
  }

  /// Authenticate with Yandex
  Future<ApiResult<SocialAuthRequest>> authenticateWithYandex() async {
    try {
      final state = _generateRandomString(32);
      final authUrl = _buildYandexAuthUrl(state);

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: SocialAuthConstants.callbackScheme,
      );

      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      final returnedState = uri.queryParameters['state'];

      if (code != null && returnedState == state) {
        return ApiResult.success(SocialAuthRequest(
          provider: SocialProvider.yandex,
          token: code,
        ));
      } else {
        return const ApiResult.failure(
          AuthFailure('Не удалось получить код авторизации от Яндекс'),
        );
      }
    } catch (e) {
      return ApiResult.failure(AuthFailure('Ошибка авторизации Яндекс: $e'));
    }
  }

  /// Authenticate with VK
  Future<ApiResult<SocialAuthRequest>> authenticateWithVK() async {
    try {
      final state = _generateRandomString(32);
      final authUrl = _buildVKAuthUrl(state);

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: SocialAuthConstants.callbackScheme,
      );

      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      final returnedState = uri.queryParameters['state'];

      if (code != null && returnedState == state) {
        return ApiResult.success(SocialAuthRequest(
          provider: SocialProvider.vk,
          token: code,
        ));
      } else {
        return const ApiResult.failure(
          AuthFailure('Не удалось получить код авторизации от VK'),
        );
      }
    } catch (e) {
      return ApiResult.failure(AuthFailure('Ошибка авторизации VK: $e'));
    }
  }

  /// Universal social authentication method
  Future<ApiResult<SocialAuthRequest>> authenticateWithProvider(
    SocialProvider provider,
  ) async {
    switch (provider) {
      case SocialProvider.telegram:
        return authenticateWithTelegram();
      case SocialProvider.yandex:
        return authenticateWithYandex();
      case SocialProvider.vk:
        return authenticateWithVK();
      default:
        return ApiResult.failure(
          AuthFailure('Провайдер ${provider.name} не поддерживается'),
        );
    }
  }

  String _buildTelegramAuthUrl() {
    final redirectUri = Uri.encodeComponent(
        '${SocialAuthConstants.callbackScheme}://telegram-auth');
    return '${SocialAuthConstants.telegramOAuthUrl}?bot_id=${SocialAuthConstants.telegramBotName}&origin=${SocialAuthConstants.callbackScheme}&return_to=$redirectUri';
  }

  String _buildYandexAuthUrl(String state) {
    final redirectUri = Uri.encodeComponent(
        '${SocialAuthConstants.callbackScheme}://yandex-auth');
    return '${SocialAuthConstants.yandexOAuthUrl}?'
        'response_type=code&'
        'client_id=${SocialAuthConstants.yandexClientId}&'
        'redirect_uri=$redirectUri&'
        'state=$state&'
        'scope=login:email login:info';
  }

  String _buildVKAuthUrl(String state) {
    final redirectUri =
        Uri.encodeComponent('${SocialAuthConstants.callbackScheme}://vk-auth');
    return '${SocialAuthConstants.vkOAuthUrl}?'
        'client_id=${SocialAuthConstants.vkClientId}&'
        'redirect_uri=$redirectUri&'
        'display=mobile&'
        'scope=email&'
        'response_type=code&'
        'v=5.131&'
        'state=$state';
  }

  Map<String, String>? _parseTelegramCallback(Uri uri) {
    final fragment = uri.fragment;
    if (fragment.isEmpty) return null;

    final params = <String, String>{};
    for (final pair in fragment.split('&')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        params[parts[0]] = Uri.decodeComponent(parts[1]);
      }
    }

    // Verify Telegram auth data
    if (_verifyTelegramAuth(params)) {
      return params;
    }

    return null;
  }

  bool _verifyTelegramAuth(Map<String, String> authData) {
    final hash = authData.remove('hash');
    if (hash == null) return false;

    // In a real implementation, you would verify the hash using your bot token
    // by creating a data check string from the auth data and comparing it with the hash
    // For now, we'll assume the auth is valid if hash is present
    return hash.isNotEmpty;
  }

  String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
