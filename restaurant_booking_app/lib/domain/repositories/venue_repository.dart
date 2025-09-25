import '../entities/venue.dart';
import '../entities/menu.dart';
import '../../core/network/api_result.dart';

abstract class VenueRepository {
  /// Search venues with filters
  Future<ApiResult<List<Venue>>> searchVenues(SearchFilters filters, {int page = 1, int limit = 20});
  
  /// Get venue details by ID
  Future<ApiResult<Venue>> getVenueDetails(String venueId);
  
  /// Get venue menu
  Future<ApiResult<List<MenuItem>>> getVenueMenu(String venueId);
  
  /// Get available time slots for booking
  Future<ApiResult<List<TimeSlot>>> getAvailableSlots(String venueId, DateTime date);
  
  /// Get user's favorite venues
  Future<ApiResult<List<String>>> getFavoriteVenues();
  
  /// Add venue to favorites
  Future<ApiResult<void>> addToFavorites(String venueId);
  
  /// Remove venue from favorites
  Future<ApiResult<void>> removeFromFavorites(String venueId);
}

class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;
  final String? venueResponse;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    this.venueResponse,
  });
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