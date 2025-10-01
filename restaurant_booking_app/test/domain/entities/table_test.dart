import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/table.dart';

void main() {
  group('Table', () {
    late Table table;

    setUp(() {
      table = const Table(
        id: 'table-123',
        venueId: 'venue-456',
        name: 'T1',
        minCapacity: 2,
        maxCapacity: 6,
        type: TableType.standard,
        location: TableLocation.window,
        amenities: ['wifi', 'charging'],
        isActive: true,
        reservationFee: 200.0,
      );
    });

    test('should check if can accommodate party size', () {
      expect(table.canAccommodate(4), isTrue);
      expect(table.canAccommodate(1), isFalse);
      expect(table.canAccommodate(8), isFalse);
      expect(table.canAccommodate(2), isTrue);
      expect(table.canAccommodate(6), isTrue);
    });

    test('should check amenities correctly', () {
      expect(table.hasAmenity('wifi'), isTrue);
      expect(table.hasAmenity('charging'), isTrue);
      expect(table.hasAmenity('tv'), isFalse);
    });

    test('should generate correct display name', () {
      expect(table.displayName, equals('Обычный T1'));
    });

    test('should not accommodate when inactive', () {
      final inactiveTable = table.copyWith(isActive: false);
      expect(inactiveTable.canAccommodate(4), isFalse);
    });

    test('should serialize to/from JSON correctly', () {
      final json = table.toJson();
      final fromJson = Table.fromJson(json);

      expect(fromJson, equals(table));
    });
  });

  group('TableType', () {
    test('should have correct display names', () {
      expect(TableType.standard.displayName, equals('Обычный'));
      expect(TableType.vip.displayName, equals('VIP'));
      expect(TableType.booth.displayName, equals('Кабинка'));
    });
  });

  group('TableLocation', () {
    test('should have correct display names', () {
      expect(TableLocation.window.displayName, equals('У окна'));
      expect(TableLocation.outdoor.displayName, equals('На улице'));
      expect(TableLocation.center.displayName, equals('В центре зала'));
    });
  });

  group('TableQuery', () {
    test('should serialize to JSON correctly', () {
      final query = TableQuery(
        venueId: 'venue-123',
        partySize: 4,
        preferredType: TableType.vip,
        preferredLocation: TableLocation.window,
        requiredAmenities: const ['wifi', 'tv'],
        dateTime: DateTime(2024, 1, 15, 18, 0),
      );

      final json = query.toJson();
      expect(json['venue_id'], equals('venue-123'));
      expect(json['party_size'], equals(4));
      expect(json['preferred_type'], equals('vip'));
      expect(json['preferred_location'], equals('window'));
      expect(json['required_amenities'], equals(['wifi', 'tv']));
    });
  });

  group('TableAvailability', () {
    late Table table;
    late TableAvailability availability;

    setUp(() {
      table = const Table(
        id: 'table-123',
        venueId: 'venue-456',
        name: 'T1',
        minCapacity: 2,
        maxCapacity: 6,
        type: TableType.standard,
        location: TableLocation.window,
        reservationFee: 200.0,
      );

      availability = TableAvailability(
        table: table,
        startTime: DateTime(2024, 1, 15, 18, 0),
        endTime: DateTime(2024, 1, 15, 20, 0),
        isAvailable: true,
        dynamicPricing: 100.0,
      );
    });

    test('should calculate total cost correctly', () {
      expect(availability.totalCost, equals(300.0));
    });

    test('should handle missing fees', () {
      const tableWithoutFee = Table(
        id: 'table-123',
        venueId: 'venue-456',
        name: 'T1',
        minCapacity: 2,
        maxCapacity: 6,
        type: TableType.standard,
        location: TableLocation.window,
        isActive: true,
        reservationFee: null, // Explicitly null
      );
      final availabilityWithoutFee = TableAvailability(
        table: tableWithoutFee,
        startTime: DateTime(2024, 1, 15, 18, 0),
        endTime: DateTime(2024, 1, 15, 20, 0),
        isAvailable: true,
        dynamicPricing: null,
      );
      expect(availabilityWithoutFee.totalCost, equals(0.0));
    });

    test('should serialize to/from JSON correctly', () {
      final json = availability.toJson();
      final fromJson = TableAvailability.fromJson(json);

      expect(fromJson, equals(availability));
    });
  });
}
