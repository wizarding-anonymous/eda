# Authentication System Implementation

## Overview

This document describes the implementation of the authentication system for the Restaurant Booking App, completed as part of task 2.1 "Создать модели и интерфейсы для аутентификации".

## Implemented Components

### 1. Domain Entities

#### AuthState (`lib/domain/entities/auth.dart`)
- Enhanced with loading states, error handling, and status tracking
- Includes `AuthStatus` enum for better state management
- Added `copyWith` method for immutable state updates
- Support for initial, loading, authenticated, unauthenticated, and error states

#### AuthResult (`lib/domain/entities/auth.dart`)
- Success and failure result types
- JSON serialization support
- Proper error message handling

#### LoginRequest (`lib/domain/entities/auth.dart`)
- Support for phone, email, and social login methods
- Type-safe constructors for different authentication methods
- Includes `SocialProvider` enum for VK, Yandex, Google, Apple

#### User (`lib/domain/entities/user.dart`)
- Complete user model with preferences
- Notification settings with quiet hours
- Theme mode support
- JSON serialization

### 2. Use Cases

Created comprehensive use cases for all authentication operations:

- **LoginWithPhoneUseCase** (`lib/domain/usecases/auth/login_with_phone_usecase.dart`)
  - Send SMS code
  - Verify OTP code

- **LoginWithEmailUseCase** (`lib/domain/usecases/auth/login_with_email_usecase.dart`)
  - Email and password authentication

- **LoginWithSocialUseCase** (`lib/domain/usecases/auth/login_with_social_usecase.dart`)
  - OAuth authentication for social providers

- **LogoutUseCase** (`lib/domain/usecases/auth/logout_usecase.dart`)
  - Clean logout with token cleanup

- **RefreshTokenUseCase** (`lib/domain/usecases/auth/refresh_token_usecase.dart`)
  - Automatic token refresh

- **GetCurrentUserUseCase** (`lib/domain/usecases/auth/get_current_user_usecase.dart`)
  - Retrieve current user information

### 3. Repository Interface

#### AuthRepository (`lib/domain/repositories/auth_repository.dart`)
Complete interface with methods for:
- SMS code sending and verification
- Email/password login
- Social authentication
- Token refresh
- User profile management
- Account deletion
- Auth state streaming

### 4. Repository Implementation

#### AuthRepositoryImpl (`lib/data/repositories/auth_repository_impl.dart`)
- Full implementation of AuthRepository interface
- Token management with local storage
- Auth state streaming
- Error handling and API integration

### 5. State Management

#### AuthProvider (`lib/presentation/providers/auth_provider.dart`)
Enhanced Riverpod provider with:
- Support for all authentication methods
- Loading and error state management
- Automatic token refresh
- Proper error handling and user feedback

### 6. Services

#### AuthService (`lib/domain/services/auth_service.dart`)
High-level authentication service that:
- Manages authentication state
- Provides unified API for all auth operations
- Handles token refresh automatically
- Broadcasts state changes

#### AuthManager (`lib/core/auth/auth_manager.dart`)
Global singleton for authentication management:
- Easy access to auth state throughout the app
- Initialization management
- Stream access for reactive UI updates

### 7. Validation

Enhanced validators in `lib/core/utils/validators.dart`:
- Email validation with proper regex
- Russian phone number validation
- OTP code validation (6 digits)
- Password strength validation
- Form validation helpers

### 8. Dependency Injection

Updated DI configuration (`lib/core/di/injection.config.dart`):
- All new use cases registered
- AuthService singleton registration
- Proper dependency resolution

### 9. Tests

Comprehensive test suite:
- **Entity tests** (`test/domain/entities/auth_test.dart`)
  - AuthState creation and manipulation
  - AuthResult success/failure scenarios
  - LoginRequest type safety

- **Use case tests** (`test/domain/usecases/auth/`)
  - Phone login use case with mocks
  - Email login use case with mocks
  - Provider tests structure

- **Infrastructure tests** (`test/infrastructure_test.dart`)
  - DI registration verification
  - Dependency resolution testing

## Key Features

### 1. Type Safety
- Strongly typed authentication states
- Enum-based status tracking
- Immutable data structures

### 2. Error Handling
- Comprehensive error states
- User-friendly error messages
- Graceful failure handling

### 3. State Management
- Reactive state updates
- Loading state tracking
- Error state management

### 4. Security
- Token-based authentication
- Automatic token refresh
- Secure local storage

### 5. Extensibility
- Easy to add new authentication methods
- Modular architecture
- Clean separation of concerns

## Integration Points

### 1. UI Integration
The AuthProvider can be used in Flutter widgets:

```dart
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      loading: () => CircularProgressIndicator(),
      authenticated: (user) => HomeScreen(),
      unauthenticated: () => LoginScreen(),
      error: (error) => ErrorWidget(error),
    );
  },
)
```

### 2. API Integration
The repository implementation handles all API calls:
- Automatic token attachment
- Error response handling
- Token refresh on 401 errors

### 3. Local Storage
Secure storage of:
- Access tokens
- Refresh tokens
- User data
- Preferences

## Requirements Compliance

This implementation satisfies the requirements specified in task 2.1:

✅ **Написать User, AuthState, AuthResult модели**
- Complete User model with preferences
- Enhanced AuthState with loading/error states
- AuthResult with success/failure handling

✅ **Создать AuthRepository интерфейс с методами login/logout/refresh**
- Comprehensive AuthRepository interface
- Full implementation with all required methods
- Additional methods for profile management

✅ **Реализовать AuthProvider для управления состоянием**
- Enhanced AuthNotifier with Riverpod
- Support for all authentication methods
- Proper state management and error handling

✅ **Требования: 1.1, 1.2**
- Phone authentication with SMS (Requirement 1.1)
- Email authentication support (Requirement 1.2)
- Social authentication framework (Requirement 1.4)

## Next Steps

The authentication system is now ready for the next tasks:
- Task 2.2: Implement phone login UI screens
- Task 2.3: Implement email login UI screens  
- Task 2.4: Add social authentication integrations

The foundation is solid and extensible, making it easy to add the UI components and external service integrations in the subsequent tasks.