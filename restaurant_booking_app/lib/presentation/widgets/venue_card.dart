import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/venue.dart';

class VenueCard extends ConsumerWidget {
  final Venue venue;

  const VenueCard({
    super.key,
    required this.venue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/venues/${venue.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            _VenueImage(venue: venue),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RatingChip(
                        rating: venue.rating,
                        reviewCount: venue.reviewCount,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Cuisine and price level
                  Row(
                    children: [
                      if (venue.cuisine.isNotEmpty) ...[
                        Text(
                          venue.cuisine,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _getPriceLevelText(venue.priceLevel),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Address and distance
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.address.fullAddress,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (venue.distance != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${venue.distance!.toStringAsFixed(1)} км',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Status and categories
                  Row(
                    children: [
                      _StatusChip(isOpen: venue.isOpen),
                      const SizedBox(width: 8),
                      if (venue.categories.isNotEmpty)
                        Expanded(
                          child: Text(
                            venue.categories.take(2).join(', '),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriceLevelText(PriceLevel level) {
    switch (level) {
      case PriceLevel.budget:
        return '₽';
      case PriceLevel.moderate:
        return '₽₽';
      case PriceLevel.expensive:
        return '₽₽₽';
      case PriceLevel.luxury:
        return '₽₽₽₽';
    }
  }
}

class _VenueImage extends StatelessWidget {
  final Venue venue;

  const _VenueImage({required this.venue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: venue.photos.isNotEmpty
          ? Image.network(
              venue.photos.first,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _PlaceholderImage();
              },
            )
          : _PlaceholderImage(),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.restaurant,
        size: 64,
        color: Colors.grey,
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingChip({
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(rating),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (reviewCount > 0) ...[
            const SizedBox(width: 2),
            Text(
              '($reviewCount)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }
}

class _StatusChip extends StatelessWidget {
  final bool isOpen;

  const _StatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOpen ? 'Открыто' : 'Закрыто',
        style: TextStyle(
          color: isOpen ? Colors.green[800] : Colors.red[800],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
