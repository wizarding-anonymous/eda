import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth.dart';
import '../providers/social_auth_provider.dart';
import '../providers/auth_provider.dart';
import 'social_login_button.dart';

class SocialLoginSection extends ConsumerWidget {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialAuthState = ref.watch(socialAuthProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    ref.listen<SocialAuthState>(socialAuthProvider, (previous, next) {
      if (next.status == SocialAuthStatus.loginSuccess &&
          next.authResult != null) {
        // Update main auth state with successful social login
        authNotifier.setAuthenticatedState(
          next.authResult!.user!,
          next.authResult!.accessToken,
          next.authResult!.refreshToken,
        );

        // Clear social auth state
        ref.read(socialAuthProvider.notifier).clearState();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Успешная авторизация!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next.status == SocialAuthStatus.error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Ошибка авторизации'),
            backgroundColor: Colors.red,
          ),
        );

        // Clear error state after showing
        Future.delayed(const Duration(seconds: 3), () {
          ref.read(socialAuthProvider.notifier).clearState();
        });
      }
    });

    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'или войдите через',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        SocialLoginButton(
          provider: SocialProvider.telegram,
          onPressed: () => _handleSocialLogin(ref, SocialProvider.telegram),
          isLoading: socialAuthState.isLoading,
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          provider: SocialProvider.yandex,
          onPressed: () => _handleSocialLogin(ref, SocialProvider.yandex),
          isLoading: socialAuthState.isLoading,
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          provider: SocialProvider.vk,
          onPressed: () => _handleSocialLogin(ref, SocialProvider.vk),
          isLoading: socialAuthState.isLoading,
        ),
      ],
    );
  }

  void _handleSocialLogin(WidgetRef ref, SocialProvider provider) {
    ref.read(socialAuthProvider.notifier).loginWithSocial(provider);
  }
}
