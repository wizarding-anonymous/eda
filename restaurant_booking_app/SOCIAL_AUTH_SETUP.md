# Social Authentication Setup Guide

This document explains how to set up and use the social authentication feature for Telegram, Yandex, and VK.

## Overview

The social authentication system provides:
- OAuth integration for Telegram, Yandex, and VK
- Universal social authentication handler
- Account linking functionality
- Cross-platform support (iOS, Android, Web)

## Configuration

### 1. Update OAuth Credentials

Edit `lib/core/constants/social_auth_constants.dart` and replace the placeholder values with your actual OAuth app credentials:

```dart
class SocialAuthConstants {
  static const String telegramBotName = 'your_actual_bot_name';
  static const String yandexClientId = 'your_actual_yandex_client_id';
  static const String vkClientId = 'your_actual_vk_client_id';
  
  // ... rest of the constants
}
```

### 2. Set up OAuth Apps

#### Telegram Bot
1. Create a bot using [@BotFather](https://t.me/botfather)
2. Get your bot username (without @)
3. Set up the bot domain and callback URL

#### Yandex OAuth
1. Go to [Yandex OAuth](https://oauth.yandex.ru/)
2. Create a new application
3. Set callback URL to `restaurant-booking://yandex-auth`
4. Get your Client ID

#### VK OAuth
1. Go to [VK Developers](https://dev.vk.com/)
2. Create a new application
3. Set callback URL to `restaurant-booking://vk-auth`
4. Get your App ID

### 3. Platform-specific Setup

#### iOS
Add URL scheme to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>restaurant-booking</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>restaurant-booking</string>
        </array>
    </dict>
</array>
```

#### Android
Add intent filter to `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- Existing intent filters -->
    
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="restaurant-booking" />
    </intent-filter>
</activity>
```

## Usage

### 1. Social Login in UI

The social login section is already integrated into the main login page. You can also use it in other screens:

```dart
import 'package:restaurant_booking_app/presentation/widgets/social_login_section.dart';

// In your widget build method:
const SocialLoginSection()
```

### 2. Individual Social Login Buttons

```dart
import 'package:restaurant_booking_app/presentation/widgets/social_login_button.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';

SocialLoginButton(
  provider: SocialProvider.telegram,
  onPressed: () => _handleSocialLogin(SocialProvider.telegram),
  isLoading: false,
)
```

### 3. Account Linking

Navigate to the linked accounts screen:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LinkedAccountsScreen(),
  ),
);
```

### 4. Programmatic Social Authentication

```dart
// Using the social auth provider
final socialAuthNotifier = ref.read(socialAuthProvider.notifier);

// Login with social provider
await socialAuthNotifier.loginWithSocial(SocialProvider.telegram);

// Link social account
await socialAuthNotifier.linkSocialAccount(SocialProvider.yandex);

// Unlink social account
await socialAuthNotifier.unlinkSocialAccount(linkedAccountId);
```

## API Endpoints

The backend should implement these endpoints:

```
POST /api/v1/auth/social
POST /api/v1/auth/social/link
DELETE /api/v1/auth/social/unlink/{id}
GET /api/v1/auth/social/linked
```

### Request/Response Examples

#### Social Login
```json
POST /api/v1/auth/social
{
  "provider": "telegram",
  "token": "auth_token_from_provider",
  "additional_data": {
    "id": "123456789",
    "username": "user123",
    "first_name": "John"
  }
}
```

#### Link Account
```json
POST /api/v1/auth/social/link
{
  "provider": "yandex",
  "social_token": "yandex_auth_code"
}
```

## Security Considerations

1. **Token Validation**: Always validate OAuth tokens on the backend
2. **State Parameter**: Use state parameter for OAuth flows to prevent CSRF
3. **Secure Storage**: Store tokens securely using platform keychain/keystore
4. **Rate Limiting**: Implement rate limiting for authentication endpoints
5. **Bot Token Security**: Keep Telegram bot token secure and validate auth data

## Testing

Run the social authentication tests:

```bash
flutter test test/domain/services/social_auth_service_test.dart
```

## Troubleshooting

### Common Issues

1. **OAuth Callback Not Working**
   - Check URL scheme configuration
   - Verify callback URLs in OAuth app settings

2. **Authentication Fails**
   - Verify OAuth app credentials
   - Check network connectivity
   - Review backend logs

3. **Account Linking Issues**
   - Ensure user is authenticated before linking
   - Check if account is already linked to another user

### Debug Mode

Enable debug logging in development:

```dart
// In main.dart
if (kDebugMode) {
  // Add logging configuration
}
```

## Next Steps

1. Implement backend OAuth verification
2. Add more social providers if needed
3. Implement social profile data synchronization
4. Add analytics for social login usage