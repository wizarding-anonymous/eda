import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../domain/entities/venue.dart';
import '../providers/map_provider.dart';

class VenueMapView extends ConsumerWidget {
  final List<Venue> venues;

  const VenueMapView({
    super.key,
    required this.venues,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateProvider);
    final userLocation = ref.watch(userLocationProvider);
    final selectedVenue = ref.watch(selectedVenueProvider);

    // Update venues in map state when venues prop changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapStateProvider.notifier).updateVenues(venues);
    });

    return Column(
      children: [
        // Yandex Map
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              YandexMap(
                onMapCreated: (YandexMapController controller) {
                  ref.read(mapControllerProvider.notifier).state = controller;
                  ref.read(mapStateProvider.notifier).initializeMap();
                },
                mapObjects:
                    ref.read(mapStateProvider.notifier).createVenueMarkers(),
                onCameraPositionChanged: (CameraPosition position,
                    CameraUpdateReason reason, bool finished) {
                  if (finished) {
                    ref.read(mapCameraPositionProvider.notifier).state =
                        position;
                  }
                },
              ),

              // Location button
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: "location_btn",
                  onPressed: () async {
                    await ref
                        .read(userLocationProvider.notifier)
                        .getCurrentLocation();
                    final location = ref.read(userLocationProvider).value;
                    if (location != null) {
                      final controller = ref.read(mapControllerProvider);
                      await controller?.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: Point(
                              latitude: location.latitude,
                              longitude: location.longitude,
                            ),
                            zoom: 15,
                          ),
                        ),
                      );
                    }
                  },
                  child: userLocation.when(
                    data: (location) => const Icon(Icons.my_location),
                    loading: () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Icon(Icons.location_disabled),
                  ),
                ),
              ),

              // Loading overlay
              if (mapState.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Error overlay
              if (mapState.error != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mapState.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            // Clear error
                            ref.read(mapStateProvider.notifier).clearError();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Bottom sheet with venue list
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header with venue count
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Найдено заведений: ${venues.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (selectedVenue != null)
                        TextButton(
                          onPressed: () {
                            ref.read(selectedVenueProvider.notifier).state =
                                null;
                          },
                          child: const Text('Сбросить'),
                        ),
                    ],
                  ),
                ),

                // Venue list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: venues.length,
                    itemBuilder: (context, index) {
                      final venue = venues[index];
                      final isSelected = selectedVenue?.id == venue.id;
                      return _MapVenueCard(
                        venue: venue,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(selectedVenueProvider.notifier).state =
                              venue;
                          // Move camera to selected venue
                          final controller = ref.read(mapControllerProvider);
                          controller?.moveCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: Point(
                                  latitude: venue.coordinates.latitude,
                                  longitude: venue.coordinates.longitude,
                                ),
                                zoom: 16,
                              ),
                            ),
                          );
                        },
                        onNavigate: () {
                          ref
                              .read(mapStateProvider.notifier)
                              .navigateToVenue(venue);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapVenueCard extends StatelessWidget {
  final Venue venue;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onNavigate;

  const _MapVenueCard({
    required this.venue,
    this.isSelected = false,
    this.onTap,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          child: const Icon(
            Icons.restaurant,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          venue.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.address.fullAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  venue.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (venue.distance != null) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${venue.distance!.toStringAsFixed(1)} км',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: venue.isOpen ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                venue.isOpen ? 'Открыто' : 'Закрыто',
                style: TextStyle(
                  color: venue.isOpen ? Colors.green[800] : Colors.red[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.directions),
              onPressed: onNavigate,
              tooltip: 'Построить маршрут',
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
