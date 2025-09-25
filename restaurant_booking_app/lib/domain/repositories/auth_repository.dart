import '../entities/auth.dart';
import '../entities/user.dart';
import '../../core/network/api_result.dart';

abstract class AuthRepository {
  /// Send SMS code to phone number
  Future<ApiResult<void>> sendSmsCode(String phone);
  
  /// Verify SMS code and login
  Future<ApiResult<AuthResult>> verifyOtp(String phone, String code);
  
  /// Register with email and password
  Future<ApiResult<AuthResult>> registerWithEmail(String name, String email, String password);

  /// Login with email and password
  Future<ApiResult<AuthResult>> loginWithEmail(String email, String password);
  
  /// Login with social provider
  Future<ApiResult<AuthResult>> loginWithSocial(String token, SocialProvider provider);
  
  /// Refresh authentication token
  Future<ApiResult<AuthResult>> refreshToken(String refreshToken);
  
  /// Logout user
  Future<ApiResult<void>> logout();
  
  /// Get current authentication state
  Stream<AuthState> get authStateChanges;
  
  /// Get current user
  Future<ApiResult<User?>> getCurrentUser();
  
  /// Update user profile
  Future<ApiResult<User>> updateProfile(User user);
  
  /// Delete user account
  Future<ApiResult<void>> deleteAccount();
  
  /// Request password reset
  Future<ApiResult<void>> requestPasswordReset(String email);
  
  /// Reset password with token
  Future<ApiResult<void>> resetPassword(String token, String newPassword);
}