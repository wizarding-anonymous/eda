import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/forgot_password_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth_layout.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final theme = Theme.of(context);

    // Update loading state
    if (_isLoading != forgotPasswordState.isLoading) {
      _isLoading = forgotPasswordState.isLoading;
    }

    // Show success message and navigate
    if (forgotPasswordState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пароль успешно изменен'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(forgotPasswordProvider.notifier).clearState();
        context.go('/auth/email');
      });
    }

    // Show error if any
    if (forgotPasswordState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(forgotPasswordState.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(forgotPasswordProvider.notifier).clearError();
      });
    }

    return AuthLayout(
      title: 'Создайте новый пароль',
      subtitle: 'Введите новый пароль\nдля вашего аккаунта',
      icon: Icon(
        Icons.lock_reset_rounded,
        size: 50,
        color: theme.colorScheme.primary,
      ),
      onBackPressed: () => context.go('/auth/email'),
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Новый пароль
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                hintText: 'Введите новый пароль',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Подтверждение пароля
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                hintText: 'Введите пароль еще раз',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Подтверждение пароля обязательно';
                }
                if (value != _passwordController.text) {
                  return 'Пароли не совпадают';
                }
                return null;
              },
              enabled: !_isLoading,
              onFieldSubmitted: (_) => _resetPassword(),
            ),
            const SizedBox(height: 32),

            // Кнопка изменения пароля
            AuthButton(
              text: 'Изменить пароль',
              onPressed: _isLoading ? null : _resetPassword,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Вернуться к входу
            TextButton(
              onPressed: _isLoading ? null : () => context.go('/auth/email'),
              child: Text(
                'Вернуться к входу',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _passwordController.text;
    await ref
        .read(forgotPasswordProvider.notifier)
        .resetPassword(widget.token, newPassword);
  }
}
