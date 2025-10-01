import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/time_slot.dart';

void main() {
  group('TimeSlot', () {
    late TimeSlot timeSlot;

    setUp(() {
      timeSlot = TimeSlot(
        id: 'slot-123',
        venueId: 'venue-456',
        startTime: DateTime(2024, 1, 15, 18, 0),
        endTime: DateTime(2024, 1, 15, 20, 0),
        maxCapacity: 10,
        currentBookings: 3,
        isAvailable: true,
        depositRequired: 500.0,
        tableType: 'standard',
      );
    });

    test('should calculate duration correctly', () {
      expect(timeSlot.durationInMinutes, equals(120));
    });

    test('should calculate available capacity correctly', () {
      expect(timeSlot.availableCapacity, equals(7));
    });

    test('should check if can accommodate party size', () {
      expect(timeSlot.canAccommodate(5), isTrue);
      expect(timeSlot.canAccommodate(8), isFalse);
      expect(timeSlot.canAccommodate(7), isTrue);
    });

    test('should detect past time slots', () {
      final pastSlot = timeSlot.copyWith(
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      expect(pastSlot.isPast, isTrue);

      final futureSlot = timeSlot.copyWith(
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
      );
      expect(futureSlot.isPast, isFalse);
    });

    test('should detect active time slots', () {
      final now = DateTime.now();
      final activeSlot = timeSlot.copyWith(
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
      );
      expect(activeSlot.isActive, isTrue);
      expect(timeSlot.isActive, isFalse);
    });

    test('should serialize to/from JSON correctly', () {
      final json = timeSlot.toJson();
      final fromJson = TimeSlot.fromJson(json);

      expect(fromJson, equals(timeSlot));
    });

    test('should handle unavailable slots', () {
      final unavailableSlot = timeSlot.copyWith(isAvailable: false);
      expect(unavailableSlot.canAccommodate(2), isFalse);
    });
  });

  group('TimeSlotQuery', () {
    test('should serialize to JSON correctly', () {
      final query = TimeSlotQuery(
        venueId: 'venue-123',
        date: DateTime(2024, 1, 15),
        partySize: 4,
        tableType: 'vip',
        preferredDuration: const Duration(hours: 2),
      );

      final json = query.toJson();
      expect(json['venue_id'], equals('venue-123'));
      expect(json['party_size'], equals(4));
      expect(json['table_type'], equals('vip'));
      expect(json['preferred_duration'], equals(120));
    });
  });
}
