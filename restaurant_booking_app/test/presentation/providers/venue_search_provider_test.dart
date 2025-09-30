import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant_booking_app/domain/entities/venue.dart';
import 'package:restaurant_booking_app/presentation/providers/venue_search_provider.dart';

void main() {
  group('VenueSearchProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('searchFiltersProvider should have default empty filters', () {
      final filters = container.read(searchFiltersProvider);

      expect(filters.query, isNull);
      expect(filters.categories, isEmpty);
      expect(filters.cuisines, isEmpty);
      expect(filters.maxDistance, isNull);
      expect(filters.location, isNull);
      expect(filters.openNow, isFalse);
      expect(filters.priceLevel, isNull);
      expect(filters.minRating, isNull);
      expect(filters.amenities, isEmpty);
    });

    test('searchQueryProvider should have empty string as default', () {
      final query = container.read(searchQueryProvider);
      expect(query, equals(''));
    });

    test('viewModeProvider should default to list view', () {
      final viewMode = container.read(viewModeProvider);
      expect(viewMode, equals(ViewMode.list));
    });

    test('showFiltersProvider should default to false', () {
      final showFilters = container.read(showFiltersProvider);
      expect(showFilters, isFalse);
    });

    test('selectedCategoryProvider should default to null', () {
      final selectedCategory = container.read(selectedCategoryProvider);
      expect(selectedCategory, isNull);
    });

    test('should update search filters', () {
      const newFilters = SearchFilters(
        query: 'test',
        categories: ['italian'],
        openNow: true,
      );

      container.read(searchFiltersProvider.notifier).state = newFilters;

      final filters = container.read(searchFiltersProvider);
      expect(filters.query, equals('test'));
      expect(filters.categories, contains('italian'));
      expect(filters.openNow, isTrue);
    });

    test('should update search query', () {
      const query = 'pizza restaurant';

      container.read(searchQueryProvider.notifier).state = query;

      final currentQuery = container.read(searchQueryProvider);
      expect(currentQuery, equals(query));
    });

    test('should toggle view mode', () {
      // Initially list mode
      expect(container.read(viewModeProvider), equals(ViewMode.list));

      // Toggle to map mode
      container.read(viewModeProvider.notifier).state = ViewMode.map;
      expect(container.read(viewModeProvider), equals(ViewMode.map));

      // Toggle back to list mode
      container.read(viewModeProvider.notifier).state = ViewMode.list;
      expect(container.read(viewModeProvider), equals(ViewMode.list));
    });

    test('should toggle filters visibility', () {
      // Initially hidden
      expect(container.read(showFiltersProvider), isFalse);

      // Show filters
      container.read(showFiltersProvider.notifier).state = true;
      expect(container.read(showFiltersProvider), isTrue);

      // Hide filters
      container.read(showFiltersProvider.notifier).state = false;
      expect(container.read(showFiltersProvider), isFalse);
    });
  });
}
