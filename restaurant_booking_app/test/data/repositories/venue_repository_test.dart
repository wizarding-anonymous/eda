import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant_booking_app/data/repositories/venue_repository_impl.dart';
import 'package:restaurant_booking_app/data/datasources/remote/api_client.dart';
import 'package:restaurant_booking_app/domain/entities/venue.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';

import 'venue_repository_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late VenueRepositoryImpl repository;
  late MockApiClient mockApiClient;

  setUpAll(() {
    // Provide dummy values for Mockito
    provideDummy<ApiResult<Map<String, dynamic>>>(
      const ApiResult.success(<String, dynamic>{}),
    );
  });

  setUp(() {
    mockApiClient = MockApiClient();
    repository = VenueRepositoryImpl(mockApiClient);
  });

  group('VenueRepository Tests', () {
    test('should search venues with filters successfully', () async {
      // Arrange
      const filters = SearchFilters(
        query: 'pizza',
        categories: ['restaurant'],
        openNow: true,
        location: LatLng(latitude: 55.7558, longitude: 37.6176),
      );

      final mockResponse = <String, dynamic>{
        'venues': [
          <String, dynamic>{
            'id': 'venue-1',
            'name': 'Pizza Place',
            'description': 'Great pizza',
            'address': <String, dynamic>{
              'street': 'Main St',
              'city': 'Test City',
            },
            'coordinates': <String, dynamic>{
              'latitude': 55.7558,
              'longitude': 37.6176,
            },
            'photos': <String>[],
            'rating': 4.5,
            'review_count': 100,
            'categories': ['restaurant'],
            'cuisine': 'Italian',
            'price_level': 1,
            'opening_hours': <String, dynamic>{
              'hours': <String, dynamic>{},
              'is_open_24_hours': false
            },
            'amenities': <Map<String, dynamic>>[],
            'is_open': true,
          }
        ]
      };

      when(mockApiClient.get<Map<String, dynamic>>(
        '/venues',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => ApiResult.success(mockResponse));

      // Act
      final result = await repository.searchVenues(filters);

      // Assert
      expect(result.isSuccess, true);
      result.when(
        success: (venues) {
          expect(venues.length, 1);
          expect(venues.first.name, 'Pizza Place');
          expect(venues.first.categories, ['restaurant']);
        },
        failure: (_) => fail('Expected success'),
      );

      // Verify API call was made with correct parameters
      verify(mockApiClient.get<Map<String, dynamic>>(
        '/venues',
        queryParameters: {
          'page': 1,
          'limit': 20,
          'q': 'pizza',
          'categories': 'restaurant',
          'lat': 55.7558,
          'lng': 37.6176,
          'open_now': true,
        },
      )).called(1);
    });

    test('should get venue details successfully', () async {
      // Arrange
      const venueId = 'venue-123';
      final mockResponse = <String, dynamic>{
        'id': venueId,
        'name': 'Test Restaurant',
        'description': 'A great place',
        'address': <String, dynamic>{
          'street': 'Main St',
          'city': 'Test City',
        },
        'coordinates': <String, dynamic>{
          'latitude': 55.7558,
          'longitude': 37.6176,
        },
        'photos': <String>[],
        'rating': 4.5,
        'review_count': 100,
        'categories': ['restaurant'],
        'cuisine': 'Italian',
        'price_level': 1,
        'opening_hours': <String, dynamic>{
          'hours': <String, dynamic>{},
          'is_open_24_hours': false
        },
        'amenities': <Map<String, dynamic>>[],
        'is_open': true,
      };

      when(mockApiClient.get<Map<String, dynamic>>('/venues/$venueId'))
          .thenAnswer((_) async => ApiResult.success(mockResponse));

      // Act
      final result = await repository.getVenueDetails(venueId);

      // Assert
      expect(result.isSuccess, true);
      result.when(
        success: (venue) {
          expect(venue.id, venueId);
          expect(venue.name, 'Test Restaurant');
        },
        failure: (_) => fail('Expected success'),
      );
    });

    test('should get categories successfully', () async {
      // Arrange
      final mockResponse = <String, dynamic>{
        'categories': [
          <String, dynamic>{
            'id': 'cat-1',
            'name': 'Italian',
            'description': 'Italian cuisine',
            'icon_url': 'italian.png',
            'color': '#FF5722',
            'sort_order': 1,
            'is_active': true,
          },
          <String, dynamic>{
            'id': 'cat-2',
            'name': 'Asian',
            'description': 'Asian cuisine',
            'icon_url': 'asian.png',
            'color': '#4CAF50',
            'sort_order': 2,
            'is_active': true,
          }
        ]
      };

      when(mockApiClient.get<Map<String, dynamic>>('/categories'))
          .thenAnswer((_) async => ApiResult.success(mockResponse));

      // Act
      final result = await repository.getCategories();

      // Assert
      expect(result.isSuccess, true);
      result.when(
        success: (categories) {
          expect(categories.length, 2);
          expect(categories.first.name, 'Italian');
          expect(categories.last.name, 'Asian');
        },
        failure: (_) => fail('Expected success'),
      );
    });

    test('should get venues by category successfully', () async {
      // Arrange
      const categoryId = 'cat-italian';
      final mockResponse = <String, dynamic>{
        'venues': [
          <String, dynamic>{
            'id': 'venue-1',
            'name': 'Italian Place',
            'description': 'Authentic Italian',
            'address': <String, dynamic>{
              'street': 'Main St',
              'city': 'Test City',
            },
            'coordinates': <String, dynamic>{
              'latitude': 55.7558,
              'longitude': 37.6176,
            },
            'photos': <String>[],
            'rating': 4.5,
            'review_count': 100,
            'categories': ['italian'],
            'cuisine': 'Italian',
            'price_level': 1,
            'opening_hours': <String, dynamic>{
              'hours': <String, dynamic>{},
              'is_open_24_hours': false
            },
            'amenities': <Map<String, dynamic>>[],
            'is_open': true,
          }
        ]
      };

      when(mockApiClient.get<Map<String, dynamic>>(
        '/venues',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => ApiResult.success(mockResponse));

      // Act
      final result = await repository.getVenuesByCategory(categoryId);

      // Assert
      expect(result.isSuccess, true);
      result.when(
        success: (venues) {
          expect(venues.length, 1);
          expect(venues.first.name, 'Italian Place');
          expect(venues.first.categories, ['italian']);
        },
        failure: (_) => fail('Expected success'),
      );

      // Verify API call was made with correct parameters
      verify(mockApiClient.get<Map<String, dynamic>>(
        '/venues',
        queryParameters: {
          'page': 1,
          'limit': 20,
          'category_id': categoryId,
        },
      )).called(1);
    });

    test('should get available time slots successfully', () async {
      // Arrange
      const venueId = 'venue-123';
      final date = DateTime(2024, 1, 15);
      final mockResponse = <String, dynamic>{
        'slots': [
          <String, dynamic>{
            'id': 'slot-1',
            'start_time': '2024-01-15T18:00:00.000Z',
            'end_time': '2024-01-15T20:00:00.000Z',
            'available_seats': 4,
            'total_seats': 6,
            'is_available': true,
            'price': 500.0,
          }
        ]
      };

      when(mockApiClient.get<Map<String, dynamic>>(
        '/venues/$venueId/availability',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => ApiResult.success(mockResponse));

      // Act
      final result = await repository.getAvailableSlots(venueId, date);

      // Assert
      expect(result.isSuccess, true);
      result.when(
        success: (slots) {
          expect(slots.length, 1);
          expect(slots.first.id, 'slot-1');
          expect(slots.first.availableSeats, 4);
        },
        failure: (_) => fail('Expected success'),
      );

      // Verify API call was made with correct date format
      verify(mockApiClient.get<Map<String, dynamic>>(
        '/venues/$venueId/availability',
        queryParameters: {
          'date': '2024-01-15',
        },
      )).called(1);
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      const filters = SearchFilters(query: 'test');
      const failure = NetworkFailure('Network error');

      when(mockApiClient.get<Map<String, dynamic>>(
        '/venues',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => const ApiResult.failure(failure));

      // Act
      final result = await repository.searchVenues(filters);

      // Assert
      expect(result.isFailure, true);
      result.when(
        success: (_) => fail('Expected failure'),
        failure: (error) => expect(error, failure),
      );
    });
  });
}
