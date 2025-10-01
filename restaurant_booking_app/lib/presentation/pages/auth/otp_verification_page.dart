import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/auth_layout.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus on OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      });
    }

    return AuthLayout(
      title: 'Введите код из SMS',
      subtitle:
          'Код отправлен на номер\n${_formatPhoneNumber(widget.phoneNumber)}',
      icon: Icon(
        Icons.security_rounded,
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
            // Поле ввода OTP
            TextFormField(
              controller: _otpController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: 'Код подтверждения',
                hintText: '123456',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                counterText: '',
              ),
              style: AppTextStyles.otpInput.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              maxLength: 6,
              validator: Validators.validateOTP,
              enabled: !_isLoading,
              onChanged: (value) {
                // Auto-submit when 6 digits are entered
                if (value.length == 6) {
                  _verifyOtp();
                }
              },
              onFieldSubmitted: (_) => _verifyOtp(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Кнопка подтверждения
            AuthButton(
              text: 'Подтвердить',
              onPressed: _isLoading ? null : _verifyOtp,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),

            // Кнопка повторной отправки
            TextButton(
              onPressed: _canResend && !_isLoading ? _resendCode : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _canResend
                    ? 'Отправить код повторно'
                    : 'Отправить повторно через $_resendCountdown сек',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _canResend && !_isLoading
                      ? theme.colorScheme.primary
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Кнопка изменения номера
            TextButton(
              onPressed: _isLoading ? null : () => context.pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Изменить номер телефона',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text.trim();
    final success = await ref
        .read(authStateProvider.notifier)
        .verifyOtp(widget.phoneNumber, otp);

    if (success && mounted) {
      // Navigation will be handled by the auth state listener
    }
  }

  Future<void> _resendCode() async {
    final success = await ref
        .read(authStateProvider.notifier)
        .sendSmsCode(widget.phoneNumber);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Код отправлен повторно'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _startResendTimer();
    }
  }

  String _formatPhoneNumber(String phone) {
    // Format +71234567890 to +7 (123) 456-78-90
    if (phone.length >= 12 && phone.startsWith('+7')) {
      final digits = phone.substring(2);
      return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8, 10)}';
    }
    return phone;
  }
}
