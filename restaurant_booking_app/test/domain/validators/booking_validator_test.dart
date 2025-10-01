import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/reservation.dart';
import 'package:restaurant_booking_app/domain/entities/time_slot.dart';
import 'package:restaurant_booking_app/domain/entities/table.dart';
import 'package:restaurant_booking_app/domain/validators/booking_validator.dart';

void main() {
  group('BookingValidator', () {
    group('validateReservationRequest', () {
      test('should validate correct reservation request', () {
        final request = ReservationRequest(
          venueId: '12345678-1234-1234-1234-123456789012',
          dateTime: DateTime.now().add(const Duration(hours: 2)),
          partySize: 4,
          tableType: 'standard',
          notes: 'Window seat please',
        );

        final result = BookingValidator.validateReservationRequest(request);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should reject invalid venue ID', () {
        final request = ReservationRequest(
          venueId: 'invalid-id',
          dateTime: DateTime.now().add(const Duration(hours: 2)),
          partySize: 4,
        );

        final result = BookingValidator.validateReservationRequest(request);
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Некорректный формат ID заведения'));
      });

      test('should reject past date', () {
        final request = ReservationRequest(
          venueId: '12345678-1234-1234-1234-123456789012',
          dateTime: DateTime.now().subtract(const Duration(hours: 1)),
          partySize: 4,
        );

        final result = BookingValidator.validateReservationRequest(request);
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'Бронирование возможно минимум за 1 час и максимум за 30 дней'));
      });

      test('should reject invalid party size', () {
        final request = ReservationRequest(
          venueId: '12345678-1234-1234-1234-123456789012',
          dateTime: DateTime.now().add(const Duration(hours: 2)),
          partySize: 0,
        );

        final result = BookingValidator.validateReservationRequest(request);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Количество гостей должно быть от 1 до 20'));
      });

      test('should reject too long notes', () {
        final request = ReservationRequest(
          venueId: '12345678-1234-1234-1234-123456789012',
          dateTime: DateTime.now().add(const Duration(hours: 2)),
          partySize: 4,
          notes: 'a' * 501,
        );

        final result = BookingValidator.validateReservationRequest(request);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Комментарий не должен превышать 500 символов'));
      });

      test('should apply business rules for large groups', () {
        final request = ReservationRequest(
          venueId: '12345678-1234-1234-1234-123456789012',
          dateTime: DateTime.now().add(const Duration(hours: 2)),
          partySize: 15,
        );

        final result = BookingValidator.validateReservationRequest(request);
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'Для групп более 10 человек требуется бронирование минимум за 24 часа'));
      });
    });

    group('validateTimeSlotForBooking', () {
      test('should validate available time slot', () {
        final timeSlot = TimeSlot(
          id: 'slot-123',
          venueId: 'venue-456',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 4)),
          maxCapacity: 10,
          currentBookings: 2,
          isAvailable: true,
        );

        final result = BookingValidator.validateTimeSlotForBooking(timeSlot, 4);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should reject unavailable time slot', () {
        final timeSlot = TimeSlot(
          id: 'slot-123',
          venueId: 'venue-456',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 4)),
          maxCapacity: 10,
          isAvailable: false,
        );

        final result = BookingValidator.validateTimeSlotForBooking(timeSlot, 4);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Выбранное время недоступно для бронирования'));
      });

      test('should reject past time slot', () {
        final timeSlot = TimeSlot(
          id: 'slot-123',
          venueId: 'venue-456',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          maxCapacity: 10,
          isAvailable: true,
        );

        final result = BookingValidator.validateTimeSlotForBooking(timeSlot, 4);
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Нельзя забронировать время в прошлом'));
      });

      test('should reject when insufficient capacity', () {
        final timeSlot = TimeSlot(
          id: 'slot-123',
          venueId: 'venue-456',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 4)),
          maxCapacity: 10,
          currentBookings: 8,
          isAvailable: true,
        );

        final result = BookingValidator.validateTimeSlotForBooking(timeSlot, 4);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Недостаточно мест для указанного количества гостей'));
      });
    });

    group('validateTableForBooking', () {
      test('should validate suitable table', () {
        const table = Table(
          id: 'table-123',
          venueId: 'venue-456',
          name: 'T1',
          minCapacity: 2,
          maxCapacity: 6,
          type: TableType.standard,
          location: TableLocation.window,
          isActive: true,
        );

        final result =
            BookingValidator.validateTableForBooking(table, 4, 'standard');
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should reject inactive table', () {
        const table = Table(
          id: 'table-123',
          venueId: 'venue-456',
          name: 'T1',
          minCapacity: 2,
          maxCapacity: 6,
          type: TableType.standard,
          location: TableLocation.window,
          isActive: false,
        );

        final result = BookingValidator.validateTableForBooking(table, 4, null);
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Выбранный столик недоступен'));
      });

      test('should reject table with wrong capacity', () {
        const table = Table(
          id: 'table-123',
          venueId: 'venue-456',
          name: 'T1',
          minCapacity: 2,
          maxCapacity: 4,
          type: TableType.standard,
          location: TableLocation.window,
          isActive: true,
        );

        final result = BookingValidator.validateTableForBooking(table, 6, null);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Столик не подходит для указанного количества гостей'));
      });
    });

    group('validatePreorderItems', () {
      test('should validate correct preorder items', () {
        const items = [
          PreorderItem(
            menuItemId: 'item-1',
            name: 'Pizza',
            quantity: 2,
            price: 500.0,
          ),
          PreorderItem(
            menuItemId: 'item-2',
            name: 'Salad',
            quantity: 1,
            price: 300.0,
          ),
        ];

        final result = BookingValidator.validatePreorderItems(items);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should reject items with zero quantity', () {
        const items = [
          PreorderItem(
            menuItemId: 'item-1',
            name: 'Pizza',
            quantity: 0,
            price: 500.0,
          ),
        ];

        final result = BookingValidator.validatePreorderItems(items);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Количество позиции "Pizza" должно быть больше 0'));
      });

      test('should reject items with excessive quantity', () {
        const items = [
          PreorderItem(
            menuItemId: 'item-1',
            name: 'Pizza',
            quantity: 25,
            price: 500.0,
          ),
        ];

        final result = BookingValidator.validatePreorderItems(items);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Максимальное количество одной позиции: 20'));
      });

      test('should reject items with zero price', () {
        const items = [
          PreorderItem(
            menuItemId: 'item-1',
            name: 'Pizza',
            quantity: 1,
            price: 0.0,
          ),
        ];

        final result = BookingValidator.validatePreorderItems(items);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('Цена позиции "Pizza" должна быть больше 0'));
      });
    });

    group('validateReservationCancellation', () {
      test('should validate cancellation of pending reservation', () {
        final reservation = Reservation(
          id: 'res-123',
          userId: 'user-456',
          venueId: 'venue-789',
          startTime: DateTime.now().add(const Duration(hours: 4)),
          endTime: DateTime.now().add(const Duration(hours: 6)),
          partySize: 4,
          status: ReservationStatus.pending,
          preorderItems: const [],
          createdAt: DateTime.now(),
        );

        final result = BookingValidator.validateReservationCancellation(
          reservation,
          'Change of plans',
        );
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should reject cancellation of already cancelled reservation', () {
        final reservation = Reservation(
          id: 'res-123',
          userId: 'user-456',
          venueId: 'venue-789',
          startTime: DateTime.now().add(const Duration(hours: 4)),
          endTime: DateTime.now().add(const Duration(hours: 6)),
          partySize: 4,
          status: ReservationStatus.cancelled,
          preorderItems: const [],
          createdAt: DateTime.now(),
        );

        final result = BookingValidator.validateReservationCancellation(
          reservation,
          'Change of plans',
        );
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Бронирование уже отменено'));
      });

      test('should reject cancellation too close to start time', () {
        final reservation = Reservation(
          id: 'res-123',
          userId: 'user-456',
          venueId: 'venue-789',
          startTime: DateTime.now().add(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          partySize: 4,
          status: ReservationStatus.confirmed,
          preorderItems: const [],
          createdAt: DateTime.now(),
        );

        final result = BookingValidator.validateReservationCancellation(
          reservation,
          'Change of plans',
        );
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'Отмена бронирования возможна минимум за 2 часа до начала'));
      });

      test('should reject empty cancellation reason', () {
        final reservation = Reservation(
          id: 'res-123',
          userId: 'user-456',
          venueId: 'venue-789',
          startTime: DateTime.now().add(const Duration(hours: 4)),
          endTime: DateTime.now().add(const Duration(hours: 6)),
          partySize: 4,
          status: ReservationStatus.confirmed,
          preorderItems: const [],
          createdAt: DateTime.now(),
        );

        final result = BookingValidator.validateReservationCancellation(
          reservation,
          '',
        );
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Причина отмены обязательна'));
      });
    });
  });

  group('BookingValidationResult', () {
    test('should provide first error', () {
      const result = BookingValidationResult(
        isValid: false,
        errors: ['Error 1', 'Error 2', 'Error 3'],
      );

      expect(result.firstError, equals('Error 1'));
      expect(result.hasErrors, isTrue);
    });

    test('should handle no errors', () {
      const result = BookingValidationResult(
        isValid: true,
        errors: [],
      );

      expect(result.firstError, isNull);
      expect(result.hasErrors, isFalse);
      expect(result.allErrors, isEmpty);
    });

    test('should format all errors', () {
      const result = BookingValidationResult(
        isValid: false,
        errors: ['Error 1', 'Error 2'],
      );

      expect(result.allErrors, equals('Error 1\nError 2'));
    });
  });
}
