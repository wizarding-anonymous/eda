import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/venue.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/venues/search_venues_usecase.dart';
import '../../domain/usecases/venues/get_categories_usecase.dart';
import '../../domain/usecases/venues/get_venues_by_category_usecase.dart';
import '../../core/di/injection.dart';

// Search filters state
final searchFiltersProvider = StateProvider<SearchFilters>((ref) {
  return const SearchFilters();
});

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// View mode state (list or map)
enum ViewMode { list, map }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = getIt<GetCategoriesUseCase>();
  final result = await useCase();

  return result.when(
    success: (categories) => categories,
    failure: (failure) => throw Exception(failure.message),
  );
});

// Venues search provider
final venuesSearchProvider = FutureProvider<List<Venue>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final query = ref.watch(searchQueryProvider);

  // Update filters with current query
  final updatedFilters = filters.copyWith(query: query.isEmpty ? null : query);

  final useCase = getIt<SearchVenuesUseCase>();
  final result = await useCase(updatedFilters);

  return result.when(
    success: (venues) => venues,
    failure: (failure) => throw Exception(failure.message),
  );
});

// Venues by category provider
final venuesByCategoryProvider =
    FutureProvider.family<List<Venue>, String>((ref, categoryId) async {
  final useCase = getIt<GetVenuesByCategoryUseCase>();
  final result = await useCase(categoryId);

  return result.when(
    success: (venues) => venues,
    failure: (failure) => throw Exception(failure.message),
  );
});

// Selected category provider
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

// Filter visibility provider
final showFiltersProvider = StateProvider<bool>((ref) => false);
