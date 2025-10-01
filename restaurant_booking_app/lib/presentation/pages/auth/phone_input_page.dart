import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth_layout.dart';

class PhoneInputPage extends ConsumerStatefulWidget {
  const PhoneInputPage({super.key});

  @override
  ConsumerState<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends ConsumerState<PhoneInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
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
      title: 'Введите номер телефона',
      subtitle: 'Мы отправим вам SMS с кодом\nподтверждения для входа',
      icon: Icon(
        Icons.phone_android_rounded,
        size: 50,
        color: theme.brightness == Brightness.dark
            ? AppColors.darkAccent
            : AppColors.lightAccent,
      ),
      onBackPressed: () => context.pop(),
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Поле ввода телефона
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Номер телефона',
                hintText: '+7 (999) 123-45-67',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _PhoneNumberFormatter(),
              ],
              validator: Validators.validatePhone,
              enabled: !_isLoading,
              onFieldSubmitted: (_) => _sendSmsCode(),
            ),
            const SizedBox(height: 32),

            // Кнопка получения кода
            AuthButton(
              text: 'Получить код',
              onPressed: _isLoading ? null : _sendSmsCode,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Кнопка альтернативного входа
            TextButton(
              onPressed: _isLoading ? null : () => context.go('/auth/email'),
              child: Text(
                'Войти через email',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkAccent
                      : AppColors.lightAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSmsCode() async {
    if (!_formKey.currentState!.validate()) return;

    final normalizedPhone = Validators.normalizePhone(_phoneController.text);

    final success =
        await ref.read(authStateProvider.notifier).sendSmsCode(normalizedPhone);

    if (success && mounted) {
      context.push('/auth/otp', extra: normalizedPhone);
    }
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 11 digits (including country code)
    final limitedDigits = digits.length > 11 ? digits.substring(0, 11) : digits;

    // Format as +7 (XXX) XXX-XX-XX
    String formatted = '';

    if (limitedDigits.isNotEmpty) {
      // Add country code
      if (limitedDigits.startsWith('8') && limitedDigits.length > 1) {
        formatted = '+7 ';
        final phoneDigits = limitedDigits.substring(1);
        formatted += _formatPhoneDigits(phoneDigits);
      } else if (limitedDigits.startsWith('7')) {
        formatted = '+7 ';
        final phoneDigits = limitedDigits.substring(1);
        formatted += _formatPhoneDigits(phoneDigits);
      } else {
        formatted = '+7 ';
        formatted += _formatPhoneDigits(limitedDigits);
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatPhoneDigits(String digits) {
    if (digits.isEmpty) return '';

    String result = '';

    if (digits.isNotEmpty) {
      result +=
          '(${digits.substring(0, digits.length >= 3 ? 3 : digits.length)}';
      if (digits.length >= 3) {
        result += ') ';
        if (digits.length >= 6) {
          result += '${digits.substring(3, 6)}-';
          if (digits.length >= 8) {
            result += '${digits.substring(6, 8)}-';
            if (digits.length >= 10) {
              result += digits.substring(8, 10);
            } else if (digits.length > 8) {
              result += digits.substring(8);
            }
          } else if (digits.length > 6) {
            result += digits.substring(6);
          }
        } else if (digits.length > 3) {
          result += digits.substring(3);
        }
      }
    }

    return result;
  }
}
