import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_booking_app/presentation/pages/booking/booking_form_page.dart';
import 'package:restaurant_booking_app/presentation/providers/booking_form_provider.dart';
import 'package:restaurant_booking_app/domain/entities/table.dart';
import 'package:restaurant_booking_app/domain/entities/time_slot.dart';
import 'package:restaurant_booking_app/domain/repositories/booking_repository.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';

// Mock repository for testing
class MockBookingRepository extends Mock implements BookingRepository {
  @override
  Future<ApiResult<List<TimeSlot>>> getAvailableTimeSlots(
      TimeSlotQuery query) async {
    // Return empty list to avoid network calls
    return const ApiResult.success([]);
  }
}

void main() {
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
  });

  Widget createTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: 2000, // Увеличиваем высоту для размещения всех элементов
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('BookingFormPage', () {
    testWidgets('should display all form sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const BookingFormPage(
          venueId: 'test-venue-id',
          venueName: 'Test Restaurant',
        ),
      ));

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that all main sections are present
      expect(find.text('Дата посещения'), findsOneWidget);
      expect(find.text('Количество гостей'), findsOneWidget);
      expect(find.text('Тип столика (необязательно)'), findsOneWidget);
      expect(find.text('Комментарии (необязательно)'), findsOneWidget);
    });

    testWidgets('should show validation errors when form is incomplete',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const BookingFormPage(
          venueId: 'test-venue-id',
          venueName: 'Test Restaurant',
        ),
      ));

      await tester.pumpAndSettle();

      // Try to find the continue button and verify it's disabled
      final continueButton = find.text('Продолжить к подтверждению');
      expect(continueButton, findsOneWidget);

      // The button should be disabled when form is incomplete
      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: continueButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('should allow party size selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const BookingFormPage(
          venueId: 'test-venue-id',
          venueName: 'Test Restaurant',
        ),
      ));

      await tester.pumpAndSettle();

      // Find and tap a party size chip
      final partySizeChip = find.text('2 гостя');
      expect(partySizeChip, findsOneWidget);

      await tester.tap(partySizeChip);
      await tester.pumpAndSettle();

      // Verify that party size selection feedback is shown
      expect(find.textContaining('Выбрано: 2 гостя'), findsOneWidget);
    });

    testWidgets('should allow table type selection',
        (WidgetTester tester) async {
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return const MaterialApp(
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: SizedBox(
                      height: 2000,
                      child: BookingFormPage(
                        venueId: 'test-venue-id',
                        venueName: 'Test Restaurant',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find table type section
      expect(find.text('Тип столика (необязательно)'), findsOneWidget);

      // Scroll to make table type section visible
      await tester.drag(
          find.byType(SingleChildScrollView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Find table type chips
      final tableTypeChips = find.descendant(
        of: find.byType(FilterChip),
        matching: find.text(TableType.standard.displayName),
      );

      // Ensure we can find at least one chip
      expect(tableTypeChips, findsAtLeastNWidgets(1));

      // Tap the first one found
      await tester.tap(tableTypeChips.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the state was updated in the provider
      final state = container.read(bookingFormProvider);
      expect(state.selectedTableType, TableType.standard);

      // Verify that table type selection feedback is shown
      expect(
          find.textContaining(
              'Предпочтение: ${TableType.standard.displayName}'),
          findsOneWidget);
    });

    testWidgets('should allow notes input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const BookingFormPage(
          venueId: 'test-venue-id',
          venueName: 'Test Restaurant',
        ),
      ));

      await tester.pumpAndSettle();

      // Find the notes input field
      final notesField = find.byType(TextFormField).last;
      expect(notesField, findsOneWidget);

      // Enter some text
      await tester.enterText(notesField, 'Столик у окна, пожалуйста');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('Столик у окна, пожалуйста'), findsOneWidget);
    });
  });

  group('BookingFormNotifier', () {
    test('should validate form correctly', () async {
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(bookingFormProvider.notifier);

      // Initially form should be invalid
      var validation = notifier.validateForm();
      expect(validation.isValid, false);
      expect(validation.errors, isNotEmpty);

      // Set venue ID
      notifier.updateVenueId('test-venue-id');
      validation = notifier.validateForm();
      expect(validation.isValid, false);

      // Set date (без вызова updatePartySize чтобы избежать async операций)
      notifier.updateDate(DateTime.now().add(const Duration(days: 1)));
      validation = notifier.validateForm();
      expect(validation.isValid, false);

      // Ждем завершения всех async операций
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('should update form state correctly', () async {
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(bookingFormProvider.notifier);

      // Test venue ID update
      notifier.updateVenueId('test-venue-id');
      var state = container.read(bookingFormProvider);
      expect(state.venueId, 'test-venue-id');

      // Test date update
      final testDate = DateTime.now().add(const Duration(days: 1));
      notifier.updateDate(testDate);
      state = container.read(bookingFormProvider);
      expect(state.selectedDate, testDate);

      // Test table type update
      notifier.updateTableType(TableType.vip);
      state = container.read(bookingFormProvider);
      expect(state.selectedTableType, TableType.vip);

      // Test notes update
      notifier.updateNotes('Test notes');
      state = container.read(bookingFormProvider);
      expect(state.notes, 'Test notes');

      // Ждем завершения всех async операций
      await Future.delayed(const Duration(milliseconds: 100));
    });
  });
}
