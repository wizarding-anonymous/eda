import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../providers/forgot_password_provider.dart';

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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
        ref.read(forgotPasswordProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый пароль'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_reset,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 32),
              Text(
                'Создайте новый пароль',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Введите новый пароль для вашего аккаунта',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Новый пароль',
                  hintText: 'Введите новый пароль',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Подтвердите пароль',
                  hintText: 'Введите пароль еще раз',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Изменить пароль'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/auth/email'),
                child: const Text('Вернуться к входу'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _passwordController.text;
    await ref.read(forgotPasswordProvider.notifier).resetPassword(widget.token, newPassword);
  }
}