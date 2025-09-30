import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/venue.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../core/di/injection.dart';

// Provider for venue details
final venueDetailsProvider =
    FutureProvider.family<Venue, String>((ref, venueId) async {
  final repository = getIt<VenueRepository>();
  final result = await repository.getVenueDetails(venueId);

  return result.when(
    success: (venue) => venue,
    failure: (failure) => throw Exception(failure.message),
  );
});

// Provider for venue menu
final venueMenuProvider =
    FutureProvider.family<List<MenuItem>, String>((ref, venueId) async {
  final repository = getIt<VenueRepository>();
  final result = await repository.getVenueMenu(venueId);

  return result.when(
    success: (menu) => menu,
    failure: (failure) => throw Exception(failure.message),
  );
});

// Provider for venue reviews
final venueReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, venueId) async {
  final repository = getIt<VenueRepository>();
  final result = await repository.getVenueReviews(venueId);

  return result.when(
    success: (reviews) => reviews,
    failure: (failure) => throw Exception(failure.message),
  );
});

// Provider for favorite status
final venueFavoriteProvider =
    FutureProvider.family<bool, String>((ref, venueId) async {
  final repository = getIt<VenueRepository>();
  final result = await repository.isVenueFavorite(venueId);

  return result.when(
    success: (isFavorite) => isFavorite,
    failure: (failure) => false, // Default to false if error
  );
});

// Provider for managing favorite status
final venueFavoriteNotifierProvider =
    StateNotifierProvider.family<VenueFavoriteNotifier, bool, String>(
  (ref, venueId) => VenueFavoriteNotifier(venueId, ref),
);

class VenueFavoriteNotifier extends StateNotifier<bool> {
  final String venueId;
  final Ref ref;
  final VenueRepository _repository = getIt<VenueRepository>();

  VenueFavoriteNotifier(this.venueId, this.ref) : super(false) {
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final result = await _repository.isVenueFavorite(venueId);
    result.when(
      success: (isFavorite) => state = isFavorite,
      failure: (_) => state = false,
    );
  }

  Future<void> toggleFavorite() async {
    final currentState = state;

    // Optimistically update UI
    state = !currentState;

    try {
      final result = currentState
          ? await _repository.removeFromFavorites(venueId)
          : await _repository.addToFavorites(venueId);

      result.when(
        success: (_) {
          // Success - state is already updated
          // Refresh the favorites list if needed
          ref.invalidate(venueFavoriteProvider(venueId));
        },
        failure: (failure) {
          // Revert state on failure
          state = currentState;
          throw Exception(failure.message);
        },
      );
    } catch (e) {
      // Revert state on error
      state = currentState;
      rethrow;
    }
  }
}
