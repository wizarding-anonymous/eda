import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthState extends Equatable {
  final User? user;
  final bool isAuthenticated;
  final String? token;
  final String? refreshToken;
  final bool isLoading;
  final String? errorMessage;
  final AuthStatus status;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.token,
    this.refreshToken,
    this.isLoading = false,
    this.errorMessage,
    this.status = AuthStatus.initial,
  });

  const AuthState.initial()
      : user = null,
        isAuthenticated = false,
        token = null,
        refreshToken = null,
        isLoading = false,
        errorMessage = null,
        status = AuthStatus.initial;

  const AuthState.loading()
      : user = null,
        isAuthenticated = false,
        token = null,
        refreshToken = null,
        isLoading = true,
        errorMessage = null,
        status = AuthStatus.loading;

  const AuthState.authenticated({
    required this.user,
    required this.token,
    this.refreshToken,
  })  : isAuthenticated = true,
        isLoading = false,
        errorMessage = null,
        status = AuthStatus.authenticated;

  const AuthState.unauthenticated({this.errorMessage})
      : user = null,
        isAuthenticated = false,
        token = null,
        refreshToken = null,
        isLoading = false,
        status = AuthStatus.unauthenticated;

  const AuthState.error({required this.errorMessage})
      : user = null,
        isAuthenticated = false,
        token = null,
        refreshToken = null,
        isLoading = false,
        status = AuthStatus.error;

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    String? token,
    String? refreshToken,
    bool? isLoading,
    String? errorMessage,
    AuthStatus? status,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        user,
        isAuthenticated,
        token,
        refreshToken,
        isLoading,
        errorMessage,
        status,
      ];
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthResult extends Equatable {
  final bool isSuccess;
  final User? user;
  final String accessToken;
  final String refreshToken;
  final String? errorMessage;

  const AuthResult.success({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  })  : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure({required this.errorMessage})
      : isSuccess = false,
        user = null,
        accessToken = '',
        refreshToken = '';

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult.success(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  List<Object?> get props => [isSuccess, user, accessToken, refreshToken, errorMessage];
}

class LoginRequest extends Equatable {
  final String identifier; // phone or email
  final String? password;
  final String? otpCode;
  final LoginMethod method;

  const LoginRequest.phone({
    required String phone,
    String? otpCode,
  })  : identifier = phone,
        password = null,
        otpCode = otpCode,
        method = LoginMethod.phone;

  const LoginRequest.email({
    required String email,
    required String password,
  })  : identifier = email,
        password = password,
        otpCode = null,
        method = LoginMethod.email;

  const LoginRequest.social({
    required String token,
    required SocialProvider provider,
  })  : identifier = token,
        password = null,
        otpCode = null,
        method = LoginMethod.social;

  @override
  List<Object?> get props => [identifier, password, otpCode, method];
}

enum LoginMethod { phone, email, social }

enum SocialProvider { vk, yandex, google, apple }