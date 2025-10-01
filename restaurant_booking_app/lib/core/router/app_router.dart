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
import '../../presentation/pages/venues/venues_search_page.dart';
import '../../presentation/pages/venues/venue_details_page.dart';
import '../../presentation/pages/booking/preorder_page.dart';
import '../../presentation/pages/booking/payment_method_page.dart';
import '../../presentation/pages/booking/booking_confirmation_page.dart';

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
          final phoneNumber =
              state.extra is String ? state.extra as String : null;
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
      GoRoute(
        path: '/venues/search',
        name: 'venues_search',
        builder: (context, state) => const VenuesSearchPage(),
      ),
      GoRoute(
        path: '/venues/:venueId',
        name: 'venue_details',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId'];
          if (venueId == null || venueId.isEmpty) {
            return const VenuesSearchPage();
          }
          return VenueDetailsPage(venueId: venueId);
        },
      ),
      GoRoute(
        path: '/venues/:venueId/preorder',
        name: 'preorder',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId'];
          final venueName =
              state.uri.queryParameters['venueName'] ?? 'Заведение';
          if (venueId == null || venueId.isEmpty) {
            return const VenuesSearchPage();
          }
          return PreorderPage(
            venueId: venueId,
            venueName: venueName,
          );
        },
      ),
      GoRoute(
        path: '/venues/:venueId/payment',
        name: 'payment_method',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId'];
          final venueName =
              state.uri.queryParameters['venueName'] ?? 'Заведение';
          final reservationId = state.uri.queryParameters['reservationId'];
          if (venueId == null || venueId.isEmpty) {
            return const VenuesSearchPage();
          }
          return PaymentMethodPage(
            venueId: venueId,
            venueName: venueName,
            reservationId: reservationId,
          );
        },
      ),
      GoRoute(
        path: '/venues/:venueId/confirmation',
        name: 'booking_confirmation',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId'];
          final venueName =
              state.uri.queryParameters['venueName'] ?? 'Заведение';
          final transactionId =
              state.uri.queryParameters['transactionId'] ?? '';
          final hasPreorder =
              state.uri.queryParameters['hasPreorder'] == 'true';
          if (venueId == null || venueId.isEmpty || transactionId.isEmpty) {
            return const VenuesSearchPage();
          }
          return BookingConfirmationPage(
            venueId: venueId,
            venueName: venueName,
            transactionId: transactionId,
            hasPreorder: hasPreorder,
          );
        },
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
