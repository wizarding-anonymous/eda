import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/email_login_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/auth/otp_verification_page.dart';
import '../../presentation/pages/auth/phone_input_page.dart';
import '../../presentation/pages/auth/reset_password_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/phone',
        name: 'auth_phone',
        builder: (context, state) => const PhoneInputPage(),
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'auth_otp',
        builder: (context, state) {
          final phoneNumber = state.extra is String ? state.extra as String : null;
          if (phoneNumber == null || phoneNumber.isEmpty) {
            return const PhoneInputPage();
          }
          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/auth/email',
        name: 'auth_email',
        builder: (context, state) => const EmailLoginPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'auth_forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/auth/reset-password/:token',
        name: 'auth_reset_password',
        builder: (context, state) {
          final token = state.pathParameters['token'] ??
              state.uri.queryParameters['token'] ??
              (state.extra is String ? state.extra as String : null);

          if (token == null || token.isEmpty) {
            return const ForgotPasswordPage();
          }

          return ResetPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Страница не найдена',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Путь: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
});
