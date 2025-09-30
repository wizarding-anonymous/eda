import '../entities/venue.dart';
import '../entities/menu.dart';
import '../entities/category.dart';
import '../entities/review.dart';
import '../../core/network/api_result.dart';

abstract class VenueRepository {
  /// Search venues with filters
  Future<ApiResult<List<Venue>>> searchVenues(SearchFilters filters,
      {int page = 1, int limit = 20});

  /// Get venue details by ID
  Future<ApiResult<Venue>> getVenueDetails(String venueId);

  /// Get venue menu
  Future<ApiResult<List<MenuItem>>> getVenueMenu(String venueId);

  /// Get available time slots for booking
  Future<ApiResult<List<TimeSlot>>> getAvailableSlots(
      String venueId, DateTime date);

  /// Get all available categories
  Future<ApiResult<List<Category>>> getCategories();

  /// Get venues by category
  Future<ApiResult<List<Venue>>> getVenuesByCategory(String categoryId,
      {int page = 1, int limit = 20});

  /// Get user's favorite venues
  Future<ApiResult<List<String>>> getFavoriteVenues();

  /// Add venue to favorites
  Future<ApiResult<void>> addToFavorites(String venueId);

  /// Remove venue from favorites
  Future<ApiResult<void>> removeFromFavorites(String venueId);

  /// Get venue reviews
  Future<ApiResult<List<Review>>> getVenueReviews(String venueId,
      {int page = 1, int limit = 10});

  /// Check if venue is in favorites
  Future<ApiResult<bool>> isVenueFavorite(String venueId);
}

class VenueCategory {
  final String id;
  final String name;
  final String? iconUrl;
  final int sortOrder;

  const VenueCategory({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.sortOrder,
  });
}
