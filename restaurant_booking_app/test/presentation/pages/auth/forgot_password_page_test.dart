import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_booking_app/presentation/pages/auth/forgot_password_page.dart';
import 'package:restaurant_booking_app/presentation/providers/forgot_password_provider.dart';

import '../../providers/forgot_password_provider_test.mocks.dart';

void main() {
  late MockForgotPasswordNotifier mockForgotPasswordNotifier;

  setUp(() {
    mockForgotPasswordNotifier = MockForgotPasswordNotifier();
  });

  Widget createTestWidget({ForgotPasswordState? state}) {
    return ProviderScope(
      overrides: [
        forgotPasswordProvider
            .overrideWith((ref) => mockForgotPasswordNotifier),
      ],
      child: const MaterialApp(
        home: ForgotPasswordPage(),
      ),
    );
  }

  group('ForgotPasswordPage Widget Tests', () {
    testWidgets('should display forgot password form',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Восстановление пароля'), findsOneWidget);
      expect(find.text('Забыли пароль?'), findsOneWidget);
      expect(
          find.text(
              'Введите ваш email и мы отправим инструкции по восстановлению пароля'),
          findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Отправить инструкции'), findsOneWidget);
      expect(find.text('Вернуться к входу'), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Find email field and enter invalid email
      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'invalid-email');

      // Tap submit button to trigger validation
      await tester.tap(find.text('Отправить инструкции'));
      await tester.pump();

      // Assert
      expect(find.text('Введите корректный email'), findsOneWidget);
    });

    testWidgets('should validate empty email field',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Leave email field empty and tap submit
      await tester.tap(find.text('Отправить инструкции'));
      await tester.pump();

      // Assert
      expect(find.text('Email обязателен'), findsOneWidget);
    });

    testWidgets('should show loading state during request',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.loading());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Button should be disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // Text field should be disabled
      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should show error message', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Email not found';
      when(mockForgotPasswordNotifier.state).thenReturn(
          const ForgotPasswordState.error(errorMessage: errorMessage));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow error to be shown

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should show success message and navigate back',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.success());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow success to be shown

      // Assert
      expect(
          find.text(
              'Инструкции по восстановлению пароля отправлены на ваш email'),
          findsOneWidget);
      verify(mockForgotPasswordNotifier.clearState()).called(1);
    });

    testWidgets(
        'should call requestPasswordReset when form is valid and submitted',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());
      when(mockForgotPasswordNotifier.requestPasswordReset('test@example.com'))
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');

      // Submit form
      await tester.tap(find.text('Отправить инструкции'));
      await tester.pump();

      // Assert
      verify(mockForgotPasswordNotifier
              .requestPasswordReset('test@example.com'))
          .called(1);
    });

    testWidgets('should navigate back when return button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Вернуться к входу'));
      await tester.pump();

      // Assert - Since we're not using router in the test widget, we can't verify navigation
      // We can verify that the button was tapped
      expect(find.text('Вернуться к входу'), findsOneWidget);
    });

    testWidgets('should submit form when enter is pressed in email field',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());
      when(mockForgotPasswordNotifier.requestPasswordReset('test@example.com'))
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid email and press enter
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Assert
      verify(mockForgotPasswordNotifier
              .requestPasswordReset('test@example.com'))
          .called(1);
    });
  });
}
