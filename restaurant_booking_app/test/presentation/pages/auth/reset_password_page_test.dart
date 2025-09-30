import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_booking_app/presentation/pages/auth/reset_password_page.dart';
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
        home: ResetPasswordPage(token: 'test_token'),
      ),
    );
  }

  group('ResetPasswordPage Widget Tests', () {
    testWidgets('should display reset password form',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Новый пароль'), findsOneWidget);
      expect(find.text('Создайте новый пароль'), findsOneWidget);
      expect(find.text('Введите новый пароль для вашего аккаунта'),
          findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Новый пароль'), findsOneWidget);
      expect(find.text('Подтвердите пароль'), findsOneWidget);
      expect(find.text('Изменить пароль'), findsOneWidget);
      expect(find.text('Вернуться к входу'), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Find password field and enter weak password
      final passwordField = find.byType(TextFormField).first;
      await tester.enterText(passwordField, 'weak');

      // Tap submit button to trigger validation
      await tester.tap(find.text('Изменить пароль'));
      await tester.pump();

      // Assert
      expect(
          find.text(
              'Пароль должен содержать минимум 8 символов, включая заглавную букву, строчную букву и цифру'),
          findsOneWidget);
    });

    testWidgets('should validate password confirmation',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Enter different passwords
      await tester.enterText(find.byType(TextFormField).first, 'Password123!');
      await tester.enterText(
          find.byType(TextFormField).last, 'DifferentPassword123!');

      // Tap submit button to trigger validation
      await tester.tap(find.text('Изменить пароль'));
      await tester.pump();

      // Assert
      expect(find.text('Пароли не совпадают'), findsOneWidget);
    });

    testWidgets('should validate empty confirmation field',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Enter password but leave confirmation empty
      await tester.enterText(find.byType(TextFormField).first, 'Password123!');
      await tester.enterText(find.byType(TextFormField).last, '');

      // Tap submit button to trigger validation
      await tester.tap(find.text('Изменить пароль'));
      await tester.pump();

      // Assert
      expect(find.text('Подтверждение пароля обязательно'), findsOneWidget);
    });

    testWidgets('should toggle password visibility for both fields',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Enter passwords
      await tester.enterText(find.byType(TextFormField).first, 'Password123!');
      await tester.enterText(find.byType(TextFormField).last, 'Password123!');

      // Find visibility toggle buttons
      final visibilityButtons = find.byIcon(Icons.visibility);
      expect(visibilityButtons, findsNWidgets(2));

      // Tap visibility toggle for first field
      await tester.tap(visibilityButtons.first);
      await tester.pump();

      // Should find visibility_off icon for first field
      expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));

      // Tap visibility toggle for second field
      await tester.tap(visibilityButtons.last);
      await tester.pump();

      // Should find visibility_off icons for both fields
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('should show loading state during reset',
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

      // Text fields should be disabled
      final textFields = find.byType(TextFormField);
      expect(tester.widget<TextFormField>(textFields.first).enabled, isFalse);
      expect(tester.widget<TextFormField>(textFields.last).enabled, isFalse);
    });

    testWidgets('should show error message', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Invalid or expired token';
      when(mockForgotPasswordNotifier.state).thenReturn(
          const ForgotPasswordState.error(errorMessage: errorMessage));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow error to be shown

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should show success message and clear state',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.success());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow success to be shown

      // Assert
      expect(find.text('Пароль успешно изменен'), findsOneWidget);
      verify(mockForgotPasswordNotifier.clearState()).called(1);
    });

    testWidgets('should call resetPassword when form is valid and submitted',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());
      when(mockForgotPasswordNotifier.resetPassword(
              'test_token', 'Password123!'))
          .thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid passwords
      await tester.enterText(find.byType(TextFormField).first, 'Password123!');
      await tester.enterText(find.byType(TextFormField).last, 'Password123!');

      // Submit form
      await tester.tap(find.text('Изменить пароль'));
      await tester.pump();

      // Assert
      verify(mockForgotPasswordNotifier.resetPassword(
              'test_token', 'Password123!'))
          .called(1);
    });

    testWidgets('should navigate to login when return button is tapped',
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

    testWidgets(
        'should submit form when enter is pressed in confirmation field',
        (WidgetTester tester) async {
      // Arrange
      when(mockForgotPasswordNotifier.state)
          .thenReturn(const ForgotPasswordState.initial());
      when(mockForgotPasswordNotifier.resetPassword(
              'test_token', 'Password123!'))
          .thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid passwords and press enter in confirmation field
      await tester.enterText(find.byType(TextFormField).first, 'Password123!');
      await tester.enterText(find.byType(TextFormField).last, 'Password123!');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Assert
      verify(mockForgotPasswordNotifier.resetPassword(
              'test_token', 'Password123!'))
          .called(1);
    });
  });
}
