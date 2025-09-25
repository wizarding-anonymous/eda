import '../entities/venue.dart';
import '../entities/menu.dart';
import '../entities/reservation.dart';
import '../../core/network/api_result.dart';

abstract class VenueRepository {
  /// Search venues with filters
  Future<ApiResult<List<Venue>>> searchVenues(SearchFilters filters, {int page = 1, int limit = 20});
  
  /// Get venue details by ID
  Future<ApiResult<Venue>> getVenueDetails(String venueId);
  
  /// Get venue menu
  Future<ApiResult<List<MenuCategory>>> getVenueMenu(String venueId);
  
  /// Get available time slots for booking
  Future<ApiResult<List<AvailableTimeSlot>>> getAvailableSlots(
    String venueId,
    DateTime date,
    int partySize,
  );
  
  /// Get venue reviews
  Future<ApiResult<List<Review>>> getVenueReviews(String venueId, {int page = 1, int limit = 20});
  
  /// Get nearby venues
  Future<ApiResult<List<Venue>>> getNearbyVenues(
    double latitude,
    double longitude,
    double radiusKm,
  );
  
  /// Get featured venues
  Future<ApiResult<List<Venue>>> getFeaturedVenues();
  
  /// Get venue categories
  Future<ApiResult<List<VenueCategory>>> getVenueCategories();
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