import 'package:injectable/injectable.dart';

import '../../domain/entities/venue.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../core/network/api_result.dart';
import '../../core/error/failures.dart';

@Singleton(as: VenueRepository)
class MockVenueRepositoryImpl implements VenueRepository {
  // Static const error instances for better performance
  static const _searchError = ServerFailure('Ошибка поиска заведений');
  static const _venueNotFoundError = ServerFailure('Заведение не найдено');
  static const _menuError = ServerFailure('Ошибка загрузки меню');
  static const _slotsError = ServerFailure('Ошибка загрузки слотов');
  static const _categoriesError = ServerFailure('Ошибка загрузки категорий');
  static const _venuesError = ServerFailure('Ошибка загрузки заведений');
  static const _reviewsError = ServerFailure('Ошибка загрузки отзывов');

  // Static const ApiResult instances for better performance
  static const _searchErrorResult =
      ApiResult<List<Venue>>.failure(_searchError);
  static const _venueNotFoundErrorResult =
      ApiResult<Venue>.failure(_venueNotFoundError);
  static const _menuErrorResult = ApiResult<List<MenuItem>>.failure(_menuError);
  static const _slotsErrorResult =
      ApiResult<List<TimeSlot>>.failure(_slotsError);
  static const _categoriesErrorResult =
      ApiResult<List<Category>>.failure(_categoriesError);
  static const _venuesErrorResult =
      ApiResult<List<Venue>>.failure(_venuesError);
  static const _reviewsErrorResult =
      ApiResult<List<Review>>.failure(_reviewsError);

  // Static const empty collections for better performance
  static const List<Venue> _emptyVenueList = <Venue>[];
  static const List<String> _mockFavorites = ['1', '2'];
  // Моковые категории
  static const List<Map<String, dynamic>> _mockCategories = [
    {
      'id': '1',
      'name': 'Итальянская',
      'description': 'Пицца, паста и другие итальянские блюда',
      'icon_url': null,
      'sort_order': 1,
    },
    {
      'id': '2',
      'name': 'Японская',
      'description': 'Суши, роллы, рамен',
      'icon_url': null,
      'sort_order': 2,
    },
    {
      'id': '3',
      'name': 'Русская',
      'description': 'Традиционная русская кухня',
      'icon_url': null,
      'sort_order': 3,
    },
    {
      'id': '4',
      'name': 'Кафе',
      'description': 'Кофе, десерты, легкие закуски',
      'icon_url': null,
      'sort_order': 4,
    },
    {
      'id': '5',
      'name': 'Фастфуд',
      'description': 'Быстрое питание',
      'icon_url': null,
      'sort_order': 5,
    },
    {
      'id': '6',
      'name': 'Бар',
      'description': 'Напитки и закуски',
      'icon_url': null,
      'sort_order': 6,
    },
  ];

  // Моковые заведения
  static const List<Map<String, dynamic>> _mockVenues = [
    {
      'id': '1',
      'name': 'Мама Рома',
      'description': 'Аутентичная итальянская кухня в сердце города',
      'address': {
        'street': 'Тверская улица',
        'city': 'Москва',
        'building': '15',
        'district': 'Центральный район',
      },
      'coordinates': {
        'latitude': 55.7558,
        'longitude': 37.6176,
      },
      'photos': [
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      ],
      'rating': 4.5,
      'review_count': 127,
      'categories': ['Итальянская'],
      'cuisine': 'Итальянская',
      'price_level': 2,
      'opening_hours': {
        'is_open_24_hours': false,
        'hours': {
          'monday': {
            'open_time': '11:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'tuesday': {
            'open_time': '11:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'wednesday': {
            'open_time': '11:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'thursday': {
            'open_time': '11:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'friday': {
            'open_time': '11:00',
            'close_time': '00:00',
            'is_closed': false
          },
          'saturday': {
            'open_time': '11:00',
            'close_time': '00:00',
            'is_closed': false
          },
          'sunday': {
            'open_time': '12:00',
            'close_time': '22:00',
            'is_closed': false
          },
        },
      },
      'amenities': [
        {'id': '1', 'name': 'Wi-Fi', 'icon': 'wifi'},
        {'id': '2', 'name': 'Терраса', 'icon': 'terrace'},
        {'id': '3', 'name': 'Оплата картой', 'icon': 'card'},
      ],
      'is_open': true,
      'distance': 1.2,
    },
    {
      'id': '2',
      'name': 'Суши Мастер',
      'description': 'Свежие суши и роллы от японского шеф-повара',
      'address': {
        'street': 'Арбат',
        'city': 'Москва',
        'building': '25',
        'district': 'Центральный район',
      },
      'coordinates': {
        'latitude': 55.7522,
        'longitude': 37.5927,
      },
      'photos': [
        'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800',
        'https://images.unsplash.com/photo-1553621042-f6e147245754?w=800',
      ],
      'rating': 4.8,
      'review_count': 89,
      'categories': ['Японская'],
      'cuisine': 'Японская',
      'price_level': 3,
      'opening_hours': {
        'is_open_24_hours': false,
        'hours': {
          'monday': {
            'open_time': '12:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'tuesday': {
            'open_time': '12:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'wednesday': {
            'open_time': '12:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'thursday': {
            'open_time': '12:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'friday': {
            'open_time': '12:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'saturday': {
            'open_time': '12:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'sunday': {
            'open_time': '12:00',
            'close_time': '21:00',
            'is_closed': false
          },
        },
      },
      'amenities': [
        {'id': '1', 'name': 'Wi-Fi', 'icon': 'wifi'},
        {'id': '4', 'name': 'Доставка', 'icon': 'delivery'},
      ],
      'is_open': true,
      'distance': 0.8,
    },
    {
      'id': '3',
      'name': 'Русская Изба',
      'description': 'Традиционная русская кухня в уютной атмосфере',
      'address': {
        'street': 'Красная площадь',
        'city': 'Москва',
        'building': '1',
        'district': 'Центральный район',
      },
      'coordinates': {
        'latitude': 55.7539,
        'longitude': 37.6208,
      },
      'photos': [
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
      ],
      'rating': 4.2,
      'review_count': 156,
      'categories': ['Русская'],
      'cuisine': 'Русская',
      'price_level': 1,
      'opening_hours': {
        'is_open_24_hours': false,
        'hours': {
          'monday': {
            'open_time': '10:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'tuesday': {
            'open_time': '10:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'wednesday': {
            'open_time': '10:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'thursday': {
            'open_time': '10:00',
            'close_time': '22:00',
            'is_closed': false
          },
          'friday': {
            'open_time': '10:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'saturday': {
            'open_time': '10:00',
            'close_time': '23:00',
            'is_closed': false
          },
          'sunday': {
            'open_time': '10:00',
            'close_time': '21:00',
            'is_closed': false
          },
        },
      },
      'amenities': [
        {'id': '2', 'name': 'Парковка', 'icon': 'parking'},
      ],
      'is_open': true,
      'distance': 2.1,
    },
  ];

  @override
  Future<ApiResult<List<Venue>>> searchVenues(
    SearchFilters filters, {
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      List<Map<String, dynamic>> filteredVenues = List.from(_mockVenues);

      // Фильтрация по запросу
      if (filters.query != null && filters.query!.isNotEmpty) {
        filteredVenues = filteredVenues.where((venue) {
          final query = filters.query!.toLowerCase();
          return venue['name'].toString().toLowerCase().contains(query) ||
              venue['cuisine'].toString().toLowerCase().contains(query) ||
              venue['description'].toString().toLowerCase().contains(query);
        }).toList();
      }

      // Фильтрация по категориям
      if (filters.categories.isNotEmpty) {
        filteredVenues = filteredVenues.where((venue) {
          final venueCategories = List<String>.from(venue['categories']);
          return filters.categories
              .any((category) => venueCategories.contains(category));
        }).toList();
      }

      // Фильтрация по кухне
      if (filters.cuisines.isNotEmpty) {
        filteredVenues = filteredVenues.where((venue) {
          return filters.cuisines.contains(venue['cuisine']);
        }).toList();
      }

      // Пагинация
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      if (startIndex >= filteredVenues.length) {
        return const ApiResult.success(_emptyVenueList);
      }

      final paginatedVenues = filteredVenues.sublist(
        startIndex,
        endIndex > filteredVenues.length ? filteredVenues.length : endIndex,
      );

      final venues =
          paginatedVenues.map((json) => Venue.fromJson(json)).toList();
      return ApiResult.success(venues);
    } catch (e) {
      return _searchErrorResult;
    }
  }

  @override
  Future<ApiResult<Venue>> getVenueDetails(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final venueData = _mockVenues.firstWhere(
        (venue) => venue['id'] == venueId,
        orElse: () => throw Exception('Заведение не найдено'),
      );

      final venue = Venue.fromJson(venueData);
      return ApiResult.success(venue);
    } catch (e) {
      return _venueNotFoundErrorResult;
    }
  }

  @override
  Future<ApiResult<List<MenuItem>>> getVenueMenu(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Моковое меню
    const mockMenu = [
      {
        'id': '1',
        'name': 'Маргарита',
        'description': 'Классическая пицца с томатами и моцареллой',
        'price': 850.0,
        'image_url':
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
        'category_id': 'main_courses',
        'allergens': ['глютен', 'молочные продукты'],
        'modifiers': [],
        'is_available': true,
        'preparation_time': 15,
      },
      {
        'id': '2',
        'name': 'Цезарь с курицей',
        'description': 'Салат с курицей, пармезаном и соусом цезарь',
        'price': 650.0,
        'image_url':
            'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
        'category_id': 'salads',
        'allergens': ['яйца', 'молочные продукты'],
        'modifiers': [],
        'is_available': true,
        'preparation_time': 10,
      },
      {
        'id': '3',
        'name': 'Тирамису',
        'description': 'Классический итальянский десерт',
        'price': 450.0,
        'image_url':
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
        'category_id': 'desserts',
        'allergens': ['яйца', 'молочные продукты', 'глютен'],
        'modifiers': [],
        'is_available': true,
        'preparation_time': 5,
      },
    ];

    try {
      final menuItems =
          mockMenu.map((json) => MenuItem.fromJson(json)).toList();
      return ApiResult.success(menuItems);
    } catch (e) {
      return _menuErrorResult;
    }
  }

  @override
  Future<ApiResult<List<TimeSlot>>> getAvailableSlots(
      String venueId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Моковые временные слоты
    final slots = <Map<String, dynamic>>[];
    final baseDate = DateTime(date.year, date.month, date.day);

    for (int hour = 12; hour <= 21; hour += 2) {
      slots.add({
        'id': 'slot_$hour',
        'start_time': baseDate.add(Duration(hours: hour)).toIso8601String(),
        'end_time': baseDate.add(Duration(hours: hour + 2)).toIso8601String(),
        'available_seats': 4,
        'total_seats': 6,
        'is_available': true,
      });
    }

    try {
      final timeSlots = slots.map((json) => TimeSlot.fromJson(json)).toList();
      return ApiResult.success(timeSlots);
    } catch (e) {
      return _slotsErrorResult;
    }
  }

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final categories =
          _mockCategories.map((json) => Category.fromJson(json)).toList();
      return ApiResult.success(categories);
    } catch (e) {
      return _categoriesErrorResult;
    }
  }

  @override
  Future<ApiResult<List<Venue>>> getVenuesByCategory(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final categoryName = _mockCategories
          .firstWhere((cat) => cat['id'] == categoryId)['name'] as String;

      final filteredVenues = _mockVenues.where((venue) {
        final categories = List<String>.from(venue['categories']);
        return categories.contains(categoryName);
      }).toList();

      final venues =
          filteredVenues.map((json) => Venue.fromJson(json)).toList();
      return ApiResult.success(venues);
    } catch (e) {
      return _venuesErrorResult;
    }
  }

  @override
  Future<ApiResult<List<String>>> getFavoriteVenues() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const ApiResult.success(_mockFavorites); // Моковые избранные
  }

  @override
  Future<ApiResult<void>> addToFavorites(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> removeFromFavorites(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<List<Review>>> getVenueReviews(
    String venueId, {
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Моковые отзывы
    const mockReviews = [
      {
        'id': '1',
        'user_id': 'user1',
        'user_name': 'Анна Петрова',
        'user_avatar_url': null,
        'rating': 5.0,
        'comment': 'Отличное место! Очень вкусная еда и приятная атмосфера.',
        'photos': [],
        'created_at': '2024-01-15T18:30:00Z',
        'venue_response': 'Спасибо за отзыв! Рады, что вам понравилось.',
        'venue_response_date': '2024-01-16T10:00:00Z',
      },
      {
        'id': '2',
        'user_id': 'user2',
        'user_name': 'Михаил Иванов',
        'user_avatar_url': null,
        'rating': 4.0,
        'comment': 'Хорошая кухня, но долго ждали заказ.',
        'photos': [],
        'created_at': '2024-01-10T20:15:00Z',
      },
    ];

    try {
      final reviews = mockReviews.map((json) => Review.fromJson(json)).toList();
      return ApiResult.success(reviews);
    } catch (e) {
      return _reviewsErrorResult;
    }
  }

  @override
  Future<ApiResult<bool>> isVenueFavorite(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Моковые избранные заведения
    return ApiResult.success(_mockFavorites.contains(venueId));
  }
}
