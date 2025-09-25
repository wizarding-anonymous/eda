import 'dart:async';

import '../../domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/services/auth_service.dart';
import '../di/injection.dart';

/// Global authentication manager singleton
class AuthManager {
  static AuthManager? _instance;
  static AuthManager get instance => _instance ??= AuthManager._();
  
  AuthManager._();
  
  late final AuthService _authService;
  bool _initialized = false;
  
  /// Initialize the auth manager
  Future<void> initialize() async {
    if (_initialized) return;
    
    _authService = getIt<AuthService>();
    await _authService.initialize();
    _initialized = true;
  }
  
  /// Current authentication state
  AuthState get currentState {
    _ensureInitialized();
    return _authService.currentState;
  }
  
  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges {
    _ensureInitialized();
    return _authService.authStateChanges;
  }
  
  /// Check if user is currently authenticated
  bool get isAuthenticated {
    _ensureInitialized();
    return _authService.isAuthenticated;
  }
  
  /// Get current user if authenticated
  User? get currentUser {
    _ensureInitialized();
    return _authService.currentUser;
  }
  
  /// Get current access token if authenticated
  String? get accessToken {
    _ensureInitialized();
    return _authService.accessToken;
  }
  
  /// Get the auth service instance
  AuthService get authService {
    _ensureInitialized();
    return _authService;
  }
  
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AuthManager must be initialized before use');
    }
  }
}