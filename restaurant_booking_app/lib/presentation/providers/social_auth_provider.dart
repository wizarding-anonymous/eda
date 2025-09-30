import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../core/di/injection.dart';

import '../../domain/entities/auth.dart';
import '../../domain/usecases/auth/login_with_social_usecase.dart';
import '../../domain/usecases/auth/link_social_account_usecase.dart';
import '../../domain/usecases/auth/unlink_social_account_usecase.dart';
import '../../domain/usecases/auth/get_linked_accounts_usecase.dart';

@injectable
class SocialAuthNotifier extends StateNotifier<SocialAuthState> {
  final LoginWithSocialUseCase _loginWithSocialUseCase;
  final LinkSocialAccountUseCase _linkSocialAccountUseCase;
  final UnlinkSocialAccountUseCase _unlinkSocialAccountUseCase;
  final GetLinkedAccountsUseCase _getLinkedAccountsUseCase;

  SocialAuthNotifier(
    this._loginWithSocialUseCase,
    this._linkSocialAccountUseCase,
    this._unlinkSocialAccountUseCase,
    this._getLinkedAccountsUseCase,
  ) : super(const SocialAuthState.initial());

  Future<void> loginWithSocial(SocialProvider provider) async {
    state = const SocialAuthState.loading();

    final result = await _loginWithSocialUseCase(provider);

    result.when(
      success: (authResult) {
        state = SocialAuthState.loginSuccess(authResult);
      },
      failure: (failure) {
        state = SocialAuthState.error(failure.message);
      },
    );
  }

  Future<void> linkSocialAccount(SocialProvider provider) async {
    state = const SocialAuthState.loading();

    final result = await _linkSocialAccountUseCase(provider);

    result.when(
      success: (linkedAccount) {
        state = SocialAuthState.linkSuccess(linkedAccount);
      },
      failure: (failure) {
        state = SocialAuthState.error(failure.message);
      },
    );
  }

  Future<void> unlinkSocialAccount(String linkedAccountId) async {
    state = const SocialAuthState.loading();

    final result = await _unlinkSocialAccountUseCase(linkedAccountId);

    result.when(
      success: (_) {
        state = const SocialAuthState.unlinkSuccess();
        // Refresh linked accounts
        loadLinkedAccounts();
      },
      failure: (failure) {
        state = SocialAuthState.error(failure.message);
      },
    );
  }

  Future<void> loadLinkedAccounts() async {
    final result = await _getLinkedAccountsUseCase();

    result.when(
      success: (linkedAccounts) {
        state = SocialAuthState.linkedAccountsLoaded(linkedAccounts);
      },
      failure: (failure) {
        state = SocialAuthState.error(failure.message);
      },
    );
  }

  void clearState() {
    state = const SocialAuthState.initial();
  }
}

class SocialAuthState {
  final bool isLoading;
  final String? errorMessage;
  final AuthResult? authResult;
  final LinkedAccount? linkedAccount;
  final List<LinkedAccount>? linkedAccounts;
  final SocialAuthStatus status;

  const SocialAuthState({
    required this.isLoading,
    this.errorMessage,
    this.authResult,
    this.linkedAccount,
    this.linkedAccounts,
    required this.status,
  });

  const SocialAuthState.initial()
      : isLoading = false,
        errorMessage = null,
        authResult = null,
        linkedAccount = null,
        linkedAccounts = null,
        status = SocialAuthStatus.initial;

  const SocialAuthState.loading()
      : isLoading = true,
        errorMessage = null,
        authResult = null,
        linkedAccount = null,
        linkedAccounts = null,
        status = SocialAuthStatus.loading;

  const SocialAuthState.loginSuccess(this.authResult)
      : isLoading = false,
        errorMessage = null,
        linkedAccount = null,
        linkedAccounts = null,
        status = SocialAuthStatus.loginSuccess;

  const SocialAuthState.linkSuccess(this.linkedAccount)
      : isLoading = false,
        errorMessage = null,
        authResult = null,
        linkedAccounts = null,
        status = SocialAuthStatus.linkSuccess;

  const SocialAuthState.unlinkSuccess()
      : isLoading = false,
        errorMessage = null,
        authResult = null,
        linkedAccount = null,
        linkedAccounts = null,
        status = SocialAuthStatus.unlinkSuccess;

  const SocialAuthState.linkedAccountsLoaded(this.linkedAccounts)
      : isLoading = false,
        errorMessage = null,
        authResult = null,
        linkedAccount = null,
        status = SocialAuthStatus.linkedAccountsLoaded;

  const SocialAuthState.error(this.errorMessage)
      : isLoading = false,
        authResult = null,
        linkedAccount = null,
        linkedAccounts = null,
        status = SocialAuthStatus.error;
}

enum SocialAuthStatus {
  initial,
  loading,
  loginSuccess,
  linkSuccess,
  unlinkSuccess,
  linkedAccountsLoaded,
  error,
}

// Provider
final socialAuthProvider =
    StateNotifierProvider<SocialAuthNotifier, SocialAuthState>(
  (ref) {
    return SocialAuthNotifier(
      getIt<LoginWithSocialUseCase>(),
      getIt<LinkSocialAccountUseCase>(),
      getIt<UnlinkSocialAccountUseCase>(),
      getIt<GetLinkedAccountsUseCase>(),
    );
  },
);
