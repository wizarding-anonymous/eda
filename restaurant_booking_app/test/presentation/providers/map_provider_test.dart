import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:restaurant_booking_app/domain/entities/venue.dart';
import 'package:restaurant_booking_app/domain/services/location_service.dart';
import 'package:restaurant_booking_app/domain/services/map_service.dart';
import 'package:restaurant_booking_app/presentation/providers/map_provider.dart';

// Generate mocks
@GenerateMocks([LocationService, MapService])
import 'map_provider_test.mocks.dart';

void main() {
  group('UserLocationNotifier', () {
    late MockLocationService mockLocationService;
    late UserLocationNotifier notifier;

    setUp(() {
      mockLocationService = MockLocationService();
      notifier = UserLocationNotifier(mockLocationService);
    });

    test('should start with loading state', () {
      expect(notifier.state, isA<AsyncLoading>());
    });

    test('should update state with location when getCurrentLocation succeeds',
        () async {
      // Arrange
      const expectedLocation = LatLng(latitude: 55.7558, longitude: 37.6176);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => expectedLocation);

      // Act
      await notifier.getCurrentLocation();

      // Assert
      expect(notifier.state, isA<AsyncData>());
      expect(notifier.state.value, equals(expectedLocation));
      verify(mockLocationService.getCurrentLocation()).called(1);
    });

    test('should update state with error when getCurrentLocation fails',
        () async {
      // Arrange
      final exception = Exception('Location error');
      when(mockLocationService.getCurrentLocation()).thenThrow(exception);

      // Act
      await notifier.getCurrentLocation();

      // Assert
      expect(notifier.state, isA<AsyncError>());
      expect(notifier.state.error, equals(exception));
      verify(mockLocationService.getCurrentLocation()).called(1);
    });

    test('should return permission status from service', () async {
      // Arrange
      when(mockLocationService.requestLocationPermission())
          .thenAnswer((_) async => true);

      // Act
      final result = await notifier.requestLocationPermission();

      // Assert
      expect(result, isTrue);
      verify(mockLocationService.requestLocationPermission()).called(1);
    });

    test('should calculate distance using service', () {
      // Arrange
      const from = LatLng(latitude: 55.7558, longitude: 37.6176);
      const to = LatLng(latitude: 59.9311, longitude: 30.3609);
      const expectedDistance = 635.0;

      when(mockLocationService.calculateDistance(from, to))
          .thenReturn(expectedDistance);

      // Act
      final result = notifier.calculateDistance(from, to);

      // Assert
      expect(result, equals(expectedDistance));
      verify(mockLocationService.calculateDistance(from, to)).called(1);
    });
  });

  group('MapStateNotifier', () {
    late MockLocationService mockLocationService;
    late MockMapService mockMapService;
    late MapStateNotifier notifier;

    setUp(() {
      mockLocationService = MockLocationService();
      mockMapService = MockMapService();
      notifier = MapStateNotifier(mockLocationService, mockMapService);
    });

    test('should start with empty state', () {
      expect(notifier.state.venues, isEmpty);
      expect(notifier.state.userLocation, isNull);
      expect(notifier.state.selectedVenue, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('should initialize map successfully', () async {
      // Arrange
      const userLocation = LatLng(latitude: 55.7558, longitude: 37.6176);
      when(mockMapService.initialize()).thenAnswer((_) async {});
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => userLocation);

      // Act
      await notifier.initializeMap();

      // Assert
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.userLocation, equals(userLocation));
      expect(notifier.state.error, isNull);
      verify(mockMapService.initialize()).called(1);
      verify(mockLocationService.getCurrentLocation()).called(1);
    });

    test('should handle initialization error', () async {
      // Arrange
      final exception = Exception('Initialization failed');
      when(mockMapService.initialize()).thenThrow(exception);

      // Act
      await notifier.initializeMap();

      // Assert
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('Failed to initialize map'));
      verify(mockMapService.initialize()).called(1);
    });

    test('should update venues with distances when user location is available',
        () {
      // Arrange
      const userLocation = LatLng(latitude: 55.7558, longitude: 37.6176);
      final venues = [
        _createTestVenue('1', 'Restaurant 1', 55.7600, 37.6200),
        _createTestVenue('2', 'Restaurant 2', 55.7650, 37.6250),
      ];

      notifier.state = notifier.state.copyWith(userLocation: userLocation);

      when(mockLocationService.calculateDistance(
              userLocation, venues[0].coordinates))
          .thenReturn(1.5);
      when(mockLocationService.calculateDistance(
              userLocation, venues[1].coordinates))
          .thenReturn(2.0);

      // Act
      notifier.updateVenues(venues);

      // Assert
      expect(notifier.state.venues.length, equals(2));
      expect(notifier.state.venues[0].distance, equals(1.5));
      expect(notifier.state.venues[1].distance, equals(2.0));
      verify(mockLocationService.calculateDistance(
              userLocation, venues[0].coordinates))
          .called(1);
      verify(mockLocationService.calculateDistance(
              userLocation, venues[1].coordinates))
          .called(1);
    });

    test(
        'should update venues without distances when user location is not available',
        () {
      // Arrange
      final venues = [
        _createTestVenue('1', 'Restaurant 1', 55.7600, 37.6200),
        _createTestVenue('2', 'Restaurant 2', 55.7650, 37.6250),
      ];

      // Act
      notifier.updateVenues(venues);

      // Assert
      expect(notifier.state.venues.length, equals(2));
      expect(notifier.state.venues[0].distance, isNull);
      expect(notifier.state.venues[1].distance, isNull);
      verifyNever(mockLocationService.calculateDistance(any, any));
    });

    test('should select venue', () {
      // Arrange
      final venue = _createTestVenue('1', 'Restaurant 1', 55.7600, 37.6200);

      // Act
      notifier.selectVenue(venue);

      // Assert
      expect(notifier.state.selectedVenue, equals(venue));
    });

    test('should navigate to venue successfully', () async {
      // Arrange
      final venue = _createTestVenue('1', 'Restaurant 1', 55.7600, 37.6200);
      when(mockLocationService.openNavigation(venue.coordinates,
              destinationName: venue.name))
          .thenAnswer((_) async {});

      // Act
      await notifier.navigateToVenue(venue);

      // Assert
      expect(notifier.state.error, isNull);
      verify(mockLocationService.openNavigation(venue.coordinates,
              destinationName: venue.name))
          .called(1);
    });

    test('should handle navigation error', () async {
      // Arrange
      final venue = _createTestVenue('1', 'Restaurant 1', 55.7600, 37.6200);
      final exception = Exception('Navigation failed');
      when(mockLocationService.openNavigation(venue.coordinates,
              destinationName: venue.name))
          .thenThrow(exception);

      // Act
      await notifier.navigateToVenue(venue);

      // Assert
      expect(notifier.state.error, contains('Failed to open navigation'));
      verify(mockLocationService.openNavigation(venue.coordinates,
              destinationName: venue.name))
          .called(1);
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
