import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:restaurant_booking_app/domain/entities/venue.dart';
import 'package:restaurant_booking_app/domain/services/map_service.dart';

// Generate mocks
@GenerateMocks([MapService])
import 'map_service_test.mocks.dart';

void main() {
  group('MapService', () {
    late MapServiceImpl mapService;

    setUp(() {
      mapService = MapServiceImpl();
    });

    group('convertToYandexPoint', () {
      test('should convert LatLng to Yandex Point correctly', () {
        // Arrange
        const latLng = LatLng(latitude: 55.7558, longitude: 37.6176);

        // Act
        final point = mapService.convertToYandexPoint(latLng);

        // Assert
        expect(point.latitude, equals(55.7558));
        expect(point.longitude, equals(37.6176));
      });
    });

    group('convertFromYandexPoint', () {
      test('should convert Yandex Point to LatLng correctly', () {
        // Arrange
        const point = Point(latitude: 55.7558, longitude: 37.6176);

        // Act
        final latLng = mapService.convertFromYandexPoint(point);

        // Assert
        expect(latLng.latitude, equals(55.7558));
        expect(latLng.longitude, equals(37.6176));
      });
    });

    group('createCameraPosition', () {
      test('should create camera position with correct parameters', () {
        // Arrange
        const center = LatLng(latitude: 55.7558, longitude: 37.6176);
        const zoom = 15.0;

        // Act
        final cameraPosition =
            mapService.createCameraPosition(center, zoom: zoom);

        // Assert
        expect(cameraPosition.target.latitude, equals(55.7558));
        expect(cameraPosition.target.longitude, equals(37.6176));
        expect(cameraPosition.zoom, equals(15.0));
      });

      test('should use default zoom when not specified', () {
        // Arrange
        const center = LatLng(latitude: 55.7558, longitude: 37.6176);

        // Act
        final cameraPosition = mapService.createCameraPosition(center);

        // Assert
        expect(cameraPosition.zoom, equals(14.0));
      });
    });

    group('createVenueMarkers', () {
      test('should create markers for all venues', () {
        // Arrange
        final venues = [
          _createTestVenue('1', 'Restaurant 1', 55.7558, 37.6176),
          _createTestVenue('2', 'Restaurant 2', 55.7600, 37.6200),
        ];

        // Act
        final markers = mapService.createVenueMarkers(venues);

        // Assert
        expect(markers.length, equals(2));
        expect(markers[0], isA<PlacemarkMapObject>());
        expect(markers[1], isA<PlacemarkMapObject>());
      });

      test('should return empty list for empty venues', () {
        // Arrange
        final venues = <Venue>[];

        // Act
        final markers = mapService.createVenueMarkers(venues);

        // Assert
        expect(markers, isEmpty);
      });
    });
  });

  group('MockMapService', () {
    late MockMapService mockMapService;

    setUp(() {
      mockMapService = MockMapService();
    });

    test('should return mocked camera position', () {
      // Arrange
      const center = LatLng(latitude: 55.7558, longitude: 37.6176);
      const expectedCameraPosition = CameraPosition(
        target: Point(latitude: 55.7558, longitude: 37.6176),
        zoom: 14.0,
      );

      when(mockMapService.createCameraPosition(center))
          .thenReturn(expectedCameraPosition);

      // Act
      final result = mockMapService.createCameraPosition(center);

      // Assert
      expect(result.target.latitude, equals(55.7558));
      expect(result.target.longitude, equals(37.6176));
      expect(result.zoom, equals(14.0));
      verify(mockMapService.createCameraPosition(center)).called(1);
    });
  });
}

Venue _createTestVenue(String id, String name, double lat, double lng) {
  return Venue(
    id: id,
    name: name,
    description: 'Test description',
    address: const Address(
      street: 'Test Street',
      city: 'Test City',
    ),
    coordinates: LatLng(latitude: lat, longitude: lng),
    photos: const [],
    rating: 4.5,
    reviewCount: 100,
    categories: const ['restaurant'],
    cuisine: 'Test Cuisine',
    priceLevel: PriceLevel.moderate,
    openingHours: const OpeningHours(hours: {}),
    amenities: const [],
    isOpen: true,
  );
}
