import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/venue.dart';
import 'package:restaurant_booking_app/domain/entities/category.dart';

void main() {
  group('Venue Entity Tests', () {
    test('should create Venue from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'venue-123',
        'name': 'Test Restaurant',
        'description': 'A great place to eat',
        'address': {
          'street': 'Main Street',
          'city': 'Test City',
          'building': '123',
        },
        'coordinates': {
          'latitude': 55.7558,
          'longitude': 37.6176,
        },
        'photos': ['photo1.jpg', 'photo2.jpg'],
        'rating': 4.5,
        'review_count': 100,
        'categories': ['restaurant', 'italian'],
        'cuisine': 'Italian',
        'price_level': 2,
        'opening_hours': {
          'hours': {
            'monday': {
              'open_time': '09:00',
              'close_time': '22:00',
              'is_closed': false,
            }
          },
          'is_open_24_hours': false,
        },
        'amenities': [
          {
            'id': 'wifi',
            'name': 'WiFi',
            'icon': 'wifi_icon',
          }
        ],
        'is_open': true,
        'distance': 1.5,
      };

      // Act
      final venue = Venue.fromJson(json);

      // Assert
      expect(venue.id, 'venue-123');
      expect(venue.name, 'Test Restaurant');
      expect(venue.description, 'A great place to eat');
      expect(venue.address.street, 'Main Street');
      expect(venue.address.city, 'Test City');
      expect(venue.coordinates.latitude, 55.7558);
      expect(venue.coordinates.longitude, 37.6176);
      expect(venue.photos, ['photo1.jpg', 'photo2.jpg']);
      expect(venue.rating, 4.5);
      expect(venue.reviewCount, 100);
      expect(venue.categories, ['restaurant', 'italian']);
      expect(venue.cuisine, 'Italian');
      expect(venue.priceLevel, PriceLevel.expensive);
      expect(venue.isOpen, true);
      expect(venue.distance, 1.5);
    });

    test('should convert Venue to JSON correctly', () {
      // Arrange
      const venue = Venue(
        id: 'venue-123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: Address(
          street: 'Main Street',
          city: 'Test City',
          building: '123',
        ),
        coordinates: LatLng(latitude: 55.7558, longitude: 37.6176),
        photos: ['photo1.jpg', 'photo2.jpg'],
        rating: 4.5,
        reviewCount: 100,
        categories: ['restaurant', 'italian'],
        cuisine: 'Italian',
        priceLevel: PriceLevel.expensive,
        openingHours: OpeningHours(hours: {}),
        amenities: [
          Amenity(id: 'wifi', name: 'WiFi', icon: 'wifi_icon'),
        ],
        isOpen: true,
        distance: 1.5,
      );

      // Act
      final json = venue.toJson();

      // Assert
      expect(json['id'], 'venue-123');
      expect(json['name'], 'Test Restaurant');
      expect(json['description'], 'A great place to eat');
      expect(json['address']['street'], 'Main Street');
      expect(json['coordinates']['latitude'], 55.7558);
      expect(json['rating'], 4.5);
      expect(json['price_level'], 2);
      expect(json['is_open'], true);
      expect(json['distance'], 1.5);
    });
  });

  group('SearchFilters Tests', () {
    test('should create SearchFilters with all parameters', () {
      // Arrange
      const location = LatLng(latitude: 55.7558, longitude: 37.6176);
      const amenities = [
        Amenity(id: 'wifi', name: 'WiFi', icon: 'wifi_icon'),
      ];

      // Act
      const filters = SearchFilters(
        query: 'pizza',
        categories: ['restaurant'],
        cuisines: ['italian'],
        maxDistance: 5.0,
        location: location,
        openNow: true,
        priceLevel: PriceLevel.moderate,
        minRating: 4.0,
        amenities: amenities,
      );

      // Assert
      expect(filters.query, 'pizza');
      expect(filters.categories, ['restaurant']);
      expect(filters.cuisines, ['italian']);
      expect(filters.maxDistance, 5.0);
      expect(filters.location, location);
      expect(filters.openNow, true);
      expect(filters.priceLevel, PriceLevel.moderate);
      expect(filters.minRating, 4.0);
      expect(filters.amenities, amenities);
    });

    test('should convert SearchFilters to JSON correctly', () {
      // Arrange
      const filters = SearchFilters(
        query: 'pizza',
        categories: ['restaurant'],
        cuisines: ['italian'],
        maxDistance: 5.0,
        location: LatLng(latitude: 55.7558, longitude: 37.6176),
        openNow: true,
        priceLevel: PriceLevel.moderate,
        minRating: 4.0,
        amenities: [
          Amenity(id: 'wifi', name: 'WiFi', icon: 'wifi_icon'),
        ],
      );

      // Act
      final json = filters.toJson();

      // Assert
      expect(json['query'], 'pizza');
      expect(json['categories'], ['restaurant']);
      expect(json['cuisines'], ['italian']);
      expect(json['max_distance'], 5.0);
      expect(json['location']['latitude'], 55.7558);
      expect(json['open_now'], true);
      expect(json['price_level'], 1); // moderate = index 1
      expect(json['min_rating'], 4.0);
      expect(json['amenities'].length, 1);
    });

    test('should create SearchFilters with copyWith method', () {
      // Arrange
      const originalFilters = SearchFilters(
        query: 'pizza',
        categories: ['restaurant'],
        openNow: false,
      );

      // Act
      final updatedFilters = originalFilters.copyWith(
        query: 'burger',
        openNow: true,
      );

      // Assert
      expect(updatedFilters.query, 'burger');
      expect(updatedFilters.categories, ['restaurant']); // unchanged
      expect(updatedFilters.openNow, true); // changed
    });
  });

  group('Category Tests', () {
    test('should create Category from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'cat-123',
        'name': 'Italian Restaurant',
        'description': 'Authentic Italian cuisine',
        'icon_url': 'https://example.com/italian.png',
        'color': '#FF5722',
        'sort_order': 1,
        'is_active': true,
      };

      // Act
      final category = Category.fromJson(json);

      // Assert
      expect(category.id, 'cat-123');
      expect(category.name, 'Italian Restaurant');
      expect(category.description, 'Authentic Italian cuisine');
      expect(category.iconUrl, 'https://example.com/italian.png');
      expect(category.color, '#FF5722');
      expect(category.sortOrder, 1);
      expect(category.isActive, true);
    });

    test('should convert Category to JSON correctly', () {
      // Arrange
      const category = Category(
        id: 'cat-123',
        name: 'Italian Restaurant',
        description: 'Authentic Italian cuisine',
        iconUrl: 'https://example.com/italian.png',
        color: '#FF5722',
        sortOrder: 1,
        isActive: true,
      );

      // Act
      final json = category.toJson();

      // Assert
      expect(json['id'], 'cat-123');
      expect(json['name'], 'Italian Restaurant');
      expect(json['description'], 'Authentic Italian cuisine');
      expect(json['icon_url'], 'https://example.com/italian.png');
      expect(json['color'], '#FF5722');
      expect(json['sort_order'], 1);
      expect(json['is_active'], true);
    });

    test('should create Category with copyWith method', () {
      // Arrange
      const originalCategory = Category(
        id: 'cat-123',
        name: 'Italian Restaurant',
        sortOrder: 1,
      );

      // Act
      final updatedCategory = originalCategory.copyWith(
        name: 'Updated Italian Restaurant',
        description: 'New description',
      );

      // Assert
      expect(updatedCategory.id, 'cat-123'); // unchanged
      expect(updatedCategory.name, 'Updated Italian Restaurant'); // changed
      expect(updatedCategory.description, 'New description'); // changed
      expect(updatedCategory.sortOrder, 1); // unchanged
    });
  });

  group('TimeSlot Tests', () {
    test('should create TimeSlot from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'slot-123',
        'start_time': '2024-01-15T18:00:00.000Z',
        'end_time': '2024-01-15T20:00:00.000Z',
        'available_seats': 4,
        'total_seats': 6,
        'is_available': true,
        'price': 500.0,
      };

      // Act
      final timeSlot = TimeSlot.fromJson(json);

      // Assert
      expect(timeSlot.id, 'slot-123');
      expect(timeSlot.startTime, DateTime.parse('2024-01-15T18:00:00.000Z'));
      expect(timeSlot.endTime, DateTime.parse('2024-01-15T20:00:00.000Z'));
      expect(timeSlot.availableSeats, 4);
      expect(timeSlot.totalSeats, 6);
      expect(timeSlot.isAvailable, true);
      expect(timeSlot.price, 500.0);
    });

    test('should calculate duration correctly', () {
      // Arrange
      final timeSlot = TimeSlot(
        id: 'slot-123',
        startTime: DateTime(2024, 1, 15, 18, 0),
        endTime: DateTime(2024, 1, 15, 20, 0),
        availableSeats: 4,
        totalSeats: 6,
        isAvailable: true,
      );

      // Act & Assert
      expect(timeSlot.duration, const Duration(hours: 2));
      expect(timeSlot.isFullyBooked, false);
      expect(timeSlot.occupancyRate, closeTo(0.33, 0.01)); // (6-4)/6 = 0.33
    });
  });
}
