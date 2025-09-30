# Environment Setup

This document describes how to set up environment variables for the Restaurant Booking App.

## Environment Variables

### Required Variables

#### YANDEX_MAPS_API_KEY
- **Description**: API key for Yandex Maps integration
- **Required**: Yes (for production)
- **How to get**: 
  1. Go to [Yandex Developer Console](https://developer.tech.yandex.ru/)
  2. Create a new project or select existing one
  3. Enable MapKit API
  4. Generate API key

#### API_BASE_URL
- **Description**: Base URL for the backend API
- **Default**: `https://api.restaurant-booking.com`
- **Required**: No (uses default if not set)

### Optional Variables

#### DEBUG_MODE
- **Description**: Enable debug mode
- **Default**: `true`
- **Values**: `true` or `false`

#### ENVIRONMENT
- **Description**: Current environment
- **Default**: `development`
- **Values**: `development`, `staging`, `production`

## Setting Environment Variables

### Method 1: Using --dart-define (Recommended)

When running or building the app, use the `--dart-define` flag:

```bash
# Development
flutter run --dart-define=YANDEX_MAPS_API_KEY=your_api_key_here --dart-define=ENVIRONMENT=development

# Production build
flutter build apk --dart-define=YANDEX_MAPS_API_KEY=your_api_key_here --dart-define=ENVIRONMENT=production --dart-define=DEBUG_MODE=false
```

### Method 2: Using .env file (Development only)

Create a `.env` file in the project root:

```env
YANDEX_MAPS_API_KEY=your_api_key_here
API_BASE_URL=https://api.restaurant-booking.com
DEBUG_MODE=true
ENVIRONMENT=development
```

**Note**: Add `.env` to your `.gitignore` file to avoid committing sensitive data.

### Method 3: IDE Configuration

#### VS Code
Add to your `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Development)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=YANDEX_MAPS_API_KEY=your_api_key_here",
        "--dart-define=ENVIRONMENT=development"
      ]
    }
  ]
}
```

#### Android Studio / IntelliJ
1. Go to Run → Edit Configurations
2. Select your Flutter configuration
3. In "Additional run args", add:
   ```
   --dart-define=YANDEX_MAPS_API_KEY=your_api_key_here --dart-define=ENVIRONMENT=development
   ```

## CI/CD Setup

### GitHub Actions
Add secrets to your repository and use them in workflows:

```yaml
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=YANDEX_MAPS_API_KEY=${{ secrets.YANDEX_MAPS_API_KEY }} \
      --dart-define=ENVIRONMENT=production \
      --dart-define=DEBUG_MODE=false
```

### Other CI/CD Platforms
Set environment variables in your CI/CD platform's secret management system and reference them in your build scripts.

## Verification

To verify that environment variables are properly set, check the debug output when initializing the map service. In development mode, you'll see warnings if the API key is not configured.

## Security Notes

1. **Never commit API keys** to version control
2. **Use different API keys** for different environments
3. **Rotate API keys** regularly
4. **Restrict API key usage** in the Yandex Developer Console to your app's bundle ID/package name
5. **Monitor API key usage** to detect unauthorized access