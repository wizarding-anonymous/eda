import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/forgot_password_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth_layout.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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

    // Show success message
    if (forgotPasswordState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Инструкции по восстановлению пароля отправлены на ваш email'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(forgotPasswordProvider.notifier).clearState();
        context.pop();
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
      title: 'Забыли пароль?',
      subtitle:
          'Введите ваш email и мы отправим\nинструкции по восстановлению пароля',
      icon: Icon(
        Icons.lock_reset_rounded,
        size: 50,
        color: theme.colorScheme.primary,
      ),
      onBackPressed: () => context.pop(),
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email поле
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'example@mail.ru',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              enabled: !_isLoading,
              onFieldSubmitted: (_) => _requestPasswordReset(),
            ),
            const SizedBox(height: 32),

            // Кнопка отправки
            AuthButton(
              text: 'Отправить инструкции',
              onPressed: _isLoading ? null : _requestPasswordReset,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Вернуться к входу
            TextButton(
              onPressed: _isLoading ? null : () => context.pop(),
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

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    await ref.read(forgotPasswordProvider.notifier).requestPasswordReset(email);
  }
}
