import 'package:injectable/injectable.dart';

import '../../domain/entities/venue.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../core/network/api_result.dart';
import '../datasources/remote/api_client.dart';

@Singleton(as: VenueRepository)
class VenueRepositoryImpl implements VenueRepository {
  final ApiClient _apiClient;

  VenueRepositoryImpl(this._apiClient);

  @override
  Future<ApiResult<List<Venue>>> searchVenues(
    SearchFilters filters, {
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (filters.query != null) 'q': filters.query,
      if (filters.categories.isNotEmpty) 'categories': filters.categories.join(','),
      if (filters.maxDistance != null) 'max_distance': filters.maxDistance,
      if (filters.location != null) ...{
        'lat': filters.location!.latitude,
        'lng': filters.location!.longitude,
      },
      if (filters.openNow) 'open_now': true,
      if (filters.priceLevel != null) 'price_level': filters.priceLevel!.name,
      if (filters.amenities.isNotEmpty) 'amenities': filters.amenities.map((a) => a.name).join(','),
    };

    final result = await _apiClient.get<Map<String, dynamic>>(
      '/venues',
      queryParameters: queryParams,
    );

    return result.when(
      success: (data) {
        final venues = (data['venues'] as List)
            .map((json) => Venue.fromJson(json))
            .toList();
        return ApiResult.success(venues);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<Venue>> getVenueDetails(String venueId) async {
    final result = await _apiClient.get<Map<String, dynamic>>('/venues/$venueId');

    return result.when(
      success: (data) {
        final venue = Venue.fromJson(data);
        return ApiResult.success(venue);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<List<MenuItem>>> getVenueMenu(String venueId) async {
    final result = await _apiClient.get<Map<String, dynamic>>('/venues/$venueId/menu');

    return result.when(
      success: (data) {
        final menuItems = (data['items'] as List)
            .map((json) => MenuItem.fromJson(json))
            .toList();
        return ApiResult.success(menuItems);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<List<TimeSlot>>> getAvailableSlots(String venueId, DateTime date) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/venues/$venueId/availability',
      queryParameters: {
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      },
    );

    return result.when(
      success: (data) {
        final slots = (data['slots'] as List)
            .map((json) => TimeSlot.fromJson(json))
            .toList();
        return ApiResult.success(slots);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<List<String>>> getFavoriteVenues() async {
    final result = await _apiClient.get<Map<String, dynamic>>('/venues/favorites');

    return result.when(
      success: (data) {
        final venueIds = (data['venue_ids'] as List).cast<String>();
        return ApiResult.success(venueIds);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<void>> addToFavorites(String venueId) async {
    final result = await _apiClient.post<void>(
      '/venues/$venueId/favorite',
    );

    return result;
  }

  @override
  Future<ApiResult<void>> removeFromFavorites(String venueId) async {
    final result = await _apiClient.delete<void>(
      '/venues/$venueId/favorite',
    );

    return result;
  }
}