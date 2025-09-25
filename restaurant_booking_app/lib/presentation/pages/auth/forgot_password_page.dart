import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../providers/forgot_password_provider.dart';

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
    
    // Update loading state
    if (_isLoading != forgotPasswordState.isLoading) {
      _isLoading = forgotPasswordState.isLoading;
    }

    // Show success message
    if (forgotPasswordState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Инструкции по восстановлению пароля отправлены на ваш email'),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
        ref.read(forgotPasswordProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Восстановление пароля'),
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
                'Забыли пароль?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Введите ваш email и мы отправим инструкции по восстановлению пароля',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@mail.ru',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _requestPasswordReset(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _requestPasswordReset,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Отправить инструкции'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => context.pop(),
                child: const Text('Вернуться к входу'),
              ),
            ],
          ),
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