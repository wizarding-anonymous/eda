import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/test_users_info.dart';

class EmailLoginPage extends ConsumerStatefulWidget {
  const EmailLoginPage({super.key});

  @override
  ConsumerState<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends ConsumerState<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    // Update loading state
    if (_isLoading != authState.isLoading) {
      _isLoading = authState.isLoading;
    }

    // Navigate to home if authenticated
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    // Show error if any
    if (authState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      });
    }

    return AuthLayout(
      title: 'Войдите в аккаунт',
      subtitle: 'Введите ваш email и пароль\nдля входа в приложение',
      icon: Icon(
        Icons.email_rounded,
        size: 50,
        color: theme.colorScheme.primary,
      ),
      onBackPressed: () => context.pop(),
      form: SingleChildScrollView(
        child: Form(
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
              ),
              const SizedBox(height: 16),

              // Пароль поле
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  hintText: 'Введите пароль',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пароль обязателен';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен содержать минимум 6 символов';
                  }
                  return null;
                },
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _loginWithEmail(),
              ),
              const SizedBox(height: 32),

              // Кнопка входа
              AuthButton(
                text: 'Войти',
                onPressed: _isLoading ? null : _loginWithEmail,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // Забыли пароль
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => context.push('/auth/forgot-password'),
                child: Text(
                  'Забыли пароль?',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Войти по телефону
              TextButton(
                onPressed:
                    _isLoading ? null : () => context.push('/auth/phone'),
                child: Text(
                  'Войти по телефону',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Test users info
              const TestUsersInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref
        .read(authStateProvider.notifier)
        .loginWithEmail(email, password);

    if (success && mounted) {
      // Navigation will be handled by the auth state listener
    }
  }
}
