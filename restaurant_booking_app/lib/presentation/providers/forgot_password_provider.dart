import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../core/di/injection.dart';
import '../../domain/usecases/auth/request_password_reset_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';

final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  return ForgotPasswordNotifier();
});

class ForgotPasswordState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ForgotPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  const ForgotPasswordState.initial()
      : isLoading = false,
        isSuccess = false,
        errorMessage = null;

  const ForgotPasswordState.loading()
      : isLoading = true,
        isSuccess = false,
        errorMessage = null;

  const ForgotPasswordState.success()
      : isLoading = false,
        isSuccess = true,
        errorMessage = null;

  const ForgotPasswordState.error({required this.errorMessage})
      : isLoading = false,
        isSuccess = false;

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  ForgotPasswordNotifier()
      : _requestPasswordResetUseCase = getIt<RequestPasswordResetUseCase>(),
        _resetPasswordUseCase = getIt<ResetPasswordUseCase>(),
        super(const ForgotPasswordState.initial());

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    state = const ForgotPasswordState.loading();
    
    final result = await _requestPasswordResetUseCase.execute(email);
    
    result.when(
      success: (_) {
        state = const ForgotPasswordState.success();
      },
      failure: (failure) {
        state = ForgotPasswordState.error(errorMessage: failure.message);
      },
    );
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    state = const ForgotPasswordState.loading();
    
    final result = await _resetPasswordUseCase.execute(token, newPassword);
    
    return result.when(
      success: (_) {
        state = const ForgotPasswordState.success();
        return true;
      },
      failure: (failure) {
        state = ForgotPasswordState.error(errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear all state
  void clearState() {
    state = const ForgotPasswordState.initial();
  }
}