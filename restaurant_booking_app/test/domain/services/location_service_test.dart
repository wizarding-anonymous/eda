import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:restaurant_booking_app/domain/entities/venue.dart';
import 'package:restaurant_booking_app/domain/services/location_service.dart';

// Generate mocks
@GenerateMocks([LocationService])
import 'location_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService', () {
    late LocationServiceImpl locationService;

    setUp(() {
      locationService = LocationServiceImpl();
    });

    group('calculateDistance', () {
      test('should calculate distance between two points correctly', () {
        // Arrange
        const from = LatLng(latitude: 55.7558, longitude: 37.6176); // Moscow
        const to =
            LatLng(latitude: 59.9311, longitude: 30.3609); // St. Petersburg

        // Act
        final distance = locationService.calculateDistance(from, to);

        // Assert
        expect(distance, greaterThan(600)); // Approximately 635 km
        expect(distance, lessThan(650));
      });

      test('should return 0 for same coordinates', () {
        // Arrange
        const location = LatLng(latitude: 55.7558, longitude: 37.6176);

        // Act
        final distance = locationService.calculateDistance(location, location);

        // Assert
        expect(distance, equals(0.0));
      });
    });

    group('openNavigation', () {
      test('should handle navigation call', () async {
        // Arrange
        const destination = LatLng(latitude: 55.7558, longitude: 37.6176);

        // Act & Assert - expect it to throw since no navigation apps are available in test
        expect(
          () => locationService.openNavigation(destination,
              destinationName: 'Test Location'),
          throwsException,
        );
      });
    });
  });

  group('MockLocationService', () {
    late MockLocationService mockLocationService;

    setUp(() {
      mockLocationService = MockLocationService();
    });

    test('should return mocked location', () async {
      // Arrange
      const expectedLocation = LatLng(latitude: 55.7558, longitude: 37.6176);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => expectedLocation);

      // Act
      final result = await mockLocationService.getCurrentLocation();

      // Assert
      expect(result, equals(expectedLocation));
      verify(mockLocationService.getCurrentLocation()).called(1);
    });

    test('should return mocked permission status', () async {
      // Arrange
      when(mockLocationService.requestLocationPermission())
          .thenAnswer((_) async => true);

      // Act
      final result = await mockLocationService.requestLocationPermission();

      // Assert
      expect(result, isTrue);
      verify(mockLocationService.requestLocationPermission()).called(1);
    });

    test('should calculate distance correctly', () {
      // Arrange
      const from = LatLng(latitude: 55.7558, longitude: 37.6176);
      const to = LatLng(latitude: 59.9311, longitude: 30.3609);
      const expectedDistance = 635.0;

      when(mockLocationService.calculateDistance(from, to))
          .thenReturn(expectedDistance);

      // Act
      final result = mockLocationService.calculateDistance(from, to);

      // Assert
      expect(result, equals(expectedDistance));
      verify(mockLocationService.calculateDistance(from, to)).called(1);
    });
  });
}
