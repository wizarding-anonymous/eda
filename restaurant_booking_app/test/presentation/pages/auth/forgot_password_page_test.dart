import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_booking_app/presentation/pages/auth/forgot_password_page.dart';
import 'package:restaurant_booking_app/presentation/providers/forgot_password_provider.dart';

void main() {
  group('ForgotPasswordPage', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      );
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          forgotPasswordProvider.overrideWith((ref) => TestForgotPasswordNotifier()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('should display forgot password form', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Восстановление пароля'), findsOneWidget);
      expect(find.text('Забыли пароль?'), findsOneWidget);
      expect(find.text('Введите ваш email и мы отправим инструкции по восстановлению пароля'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Отправить инструкции'), findsOneWidget);
      expect(find.text('Вернуться к входу'), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      
      // Tap submit button to trigger validation
      await tester.tap(find.text('Отправить инструкции'));
      await tester.pump();

      expect(find.text('Введите корректный email'), findsOneWidget);
    });

    testWidgets('should show loading state during request', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');

      // Tap submit button
      await tester.tap(find.text('Отправить инструкции'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show success message on successful request', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');

      // Tap submit button
      await tester.tap(find.text('Отправить инструкции'));
      await tester.pump();
      await tester.pump(); // Wait for state change

      // Should show success snackbar
      expect(find.text('Инструкции по восстановлению пароля отправлены на ваш email'), findsOneWidget);
    });
  });
}

class TestForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  TestForgotPasswordNotifier() : super(const ForgotPasswordState.initial());

  Future<void> requestPasswordReset(String email) async {
    state = const ForgotPasswordState.loading();
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (email == 'test@example.com') {
      state = const ForgotPasswordState.success();
    } else {
      state = const ForgotPasswordState.error(errorMessage: 'Email not found');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearState() {
    state = const ForgotPasswordState.initial();
  }
}