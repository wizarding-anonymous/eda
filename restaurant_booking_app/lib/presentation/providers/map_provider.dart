import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../core/di/injection.dart';
import '../../domain/entities/venue.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/map_service.dart';

// Providers
final locationServiceProvider = Provider<LocationService>((ref) {
  return getIt<LocationService>();
});

final mapServiceProvider = Provider<MapService>((ref) {
  return getIt<MapService>();
});

final mapControllerProvider = StateProvider<YandexMapController?>((ref) {
  return null;
});

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, AsyncValue<LatLng?>>((ref) {
  return UserLocationNotifier(ref.read(locationServiceProvider));
});

final selectedVenueProvider = StateProvider<Venue?>((ref) {
  return null;
});

final mapCameraPositionProvider = StateProvider<CameraPosition?>((ref) {
  return null;
});

// State Notifiers
class UserLocationNotifier extends StateNotifier<AsyncValue<LatLng?>> {
  final LocationService _locationService;

  UserLocationNotifier(this._locationService)
      : super(const AsyncValue.loading());

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();

    try {
      final location = await _locationService.getCurrentLocation();
      state = AsyncValue.data(location);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> requestLocationPermission() async {
    return await _locationService.requestLocationPermission();
  }

  Future<bool> isLocationServiceEnabled() async {
    return await _locationService.isLocationServiceEnabled();
  }

  double calculateDistance(LatLng from, LatLng to) {
    return _locationService.calculateDistance(from, to);
  }

  Future<void> openNavigation(LatLng destination,
      {String? destinationName}) async {
    await _locationService.openNavigation(destination,
        destinationName: destinationName);
  }
}

// Map State
class MapState {
  final List<Venue> venues;
  final LatLng? userLocation;
  final Venue? selectedVenue;
  final bool isLoading;
  final String? error;

  const MapState({
    this.venues = const [],
    this.userLocation,
    this.selectedVenue,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    List<Venue>? venues,
    LatLng? userLocation,
    Venue? selectedVenue,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      venues: venues ?? this.venues,
      userLocation: userLocation ?? this.userLocation,
      selectedVenue: selectedVenue ?? this.selectedVenue,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final mapStateProvider =
    StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  return MapStateNotifier(
    ref.read(locationServiceProvider),
    ref.read(mapServiceProvider),
  );
});

class MapStateNotifier extends StateNotifier<MapState> {
  final LocationService _locationService;
  final MapService _mapService;

  MapStateNotifier(this._locationService, this._mapService)
      : super(const MapState());

  Future<void> initializeMap() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _mapService.initialize();
      await getCurrentLocation();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize map: $error',
      );
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      state = state.copyWith(userLocation: location);
    } catch (error) {
      state = state.copyWith(error: 'Failed to get location: $error');
    }
  }

  void updateVenues(List<Venue> venues) {
    // Calculate distances if user location is available
    if (state.userLocation != null) {
      final venuesWithDistance = venues.map((venue) {
        final distance = _locationService.calculateDistance(
          state.userLocation!,
          venue.coordinates,
        );
        return venue.copyWith(distance: distance);
      }).toList();

      state = state.copyWith(venues: venuesWithDistance);
    } else {
      state = state.copyWith(venues: venues);
    }
  }

  void selectVenue(Venue? venue) {
    state = state.copyWith(selectedVenue: venue);
  }

  Future<void> navigateToVenue(Venue venue) async {
    try {
      await _locationService.openNavigation(
        venue.coordinates,
        destinationName: venue.name,
      );
    } catch (error) {
      state = state.copyWith(error: 'Failed to open navigation: $error');
    }
  }

  List<MapObject> createVenueMarkers() {
    return _mapService.createVenueMarkers(
      state.venues,
      onVenueTap: selectVenue,
    );
  }

  CameraPosition? getCameraPosition() {
    if (state.userLocation != null) {
      return _mapService.createCameraPosition(state.userLocation!);
    } else if (state.venues.isNotEmpty) {
      // Center on first venue if no user location
      return _mapService.createCameraPosition(state.venues.first.coordinates);
    }
    return null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
