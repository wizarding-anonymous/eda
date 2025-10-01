import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/social_login_section.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Navigate to home if authenticated
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    return WelcomeLayout(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Основная кнопка входа по телефону
          AuthButton(
            text: 'Войти по телефону',
            icon: Icon(
              Icons.phone_rounded,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
            onPressed: () => context.push('/auth/phone'),
          ),
          const SizedBox(height: 16),

          // Вторичная кнопка входа по email
          AuthButton(
            text: 'Войти через email',
            icon: Icon(
              Icons.email_rounded,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => context.push('/auth/email'),
            isSecondary: true,
          ),
          const SizedBox(height: 32),

          // Разделитель
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'или',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Социальные сети
          const SocialLoginSection(),

          const SizedBox(height: 48),

          // Информация о регистрации
          Text(
            'Продолжая, вы соглашаетесь с условиями\nиспользования и политикой конфиденциальности',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
