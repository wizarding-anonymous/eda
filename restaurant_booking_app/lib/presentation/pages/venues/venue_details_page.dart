import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/venue_details_provider.dart';
import '../../widgets/venue_photo_gallery.dart';
import '../../widgets/venue_info_section.dart';
import '../../widgets/venue_menu_section.dart';
import '../../widgets/venue_reviews_section.dart';

class VenueDetailsPage extends ConsumerWidget {
  final String venueId;

  const VenueDetailsPage({
    super.key,
    required this.venueId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueAsync = ref.watch(venueDetailsProvider(venueId));
    final favoriteAsync = ref.watch(venueFavoriteProvider(venueId));

    return Scaffold(
      body: venueAsync.when(
        data: (venue) => CustomScrollView(
          slivers: [
            // App bar with photos
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: VenuePhotoGallery(photos: venue.photos),
              ),
              actions: [
                // Favorite button
                favoriteAsync.when(
                  data: (isFavorite) => Consumer(
                    builder: (context, ref, child) {
                      return IconButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(venueFavoriteNotifierProvider(venueId)
                                    .notifier)
                                .toggleFavorite();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ошибка: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                      );
                    },
                  ),
                  loading: () => const IconButton(
                    onPressed: null,
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                  ),
                  error: (_, __) => const IconButton(
                    onPressed: null,
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                  ),
                ),
              ],
            ),

            // Venue information
            SliverToBoxAdapter(
              child: VenueInfoSection(venue: venue),
            ),

            // Menu section
            SliverToBoxAdapter(
              child: VenueMenuSection(venueId: venueId),
            ),

            // Reviews section
            SliverToBoxAdapter(
              child: VenueReviewsSection(venueId: venueId),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(
            title: const Text('Ошибка'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Не удалось загрузить информацию о заведении',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(venueDetailsProvider(venueId)),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: venueAsync.when(
        data: (venue) => FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to booking page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Переход к бронированию')),
            );
          },
          icon: const Icon(Icons.event_available),
          label: const Text('Забронировать'),
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}
