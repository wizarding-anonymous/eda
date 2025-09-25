import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_booking_app/presentation/pages/auth/email_login_page.dart';
import 'package:restaurant_booking_app/presentation/providers/auth_provider.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';

void main() {
  group('EmailLoginPage', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const EmailLoginPage(),
          ),
          GoRoute(
            path: '/auth/forgot-password',
            builder: (context, state) => const Scaffold(
              body: Text('Forgot Password Page'),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Text('Home Page'),
            ),
          ),
        ],
      );
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => TestAuthNotifier()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('should display email login form', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Вход через email'), findsOneWidget);
      expect(find.text('Войдите в аккаунт'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Пароль'), findsOneWidget);
      expect(find.text('Войти'), findsOneWidget);
      expect(find.text('Забыли пароль?'), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the email field and enter invalid email
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');
      
      // Tap login button to trigger validation
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите корректный email'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the password field and enter short password
      final passwordField = find.widgetWithText(TextFormField, 'Пароль');
      await tester.enterText(passwordField, '123');
      
      // Tap login button to trigger validation
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Пароль должен содержать минимум 6 символов'), findsOneWidget);
    });

    testWidgets('should navigate to forgot password page', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap forgot password button
      await tester.tap(find.text('Забыли пароль?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password Page'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Пароль');
      await tester.enterText(passwordField, 'password123');
      
      // Initially password should be obscured
      TextFormField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Password should now be visible
      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isFalse);
    });

    testWidgets('should show loading state during login', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid credentials
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль'), 'password123');

      // Tap login button
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class TestAuthNotifier extends StateNotifier<AuthState> {
  TestAuthNotifier() : super(const AuthState.initial());

  Future<bool> loginWithEmail(String email, String password) async {
    state = const AuthState.loading();
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (email == 'test@example.com' && password == 'password123') {
      state = const AuthState.authenticated(
        user: null, // We'd need to create a test user here
        token: 'test_token',
      );
      return true;
    } else {
      state = const AuthState.error(errorMessage: 'Invalid credentials');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}