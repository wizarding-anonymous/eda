import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/venue.dart';

class VenueInfoSection extends StatelessWidget {
  final Venue venue;

  const VenueInfoSection({
    super.key,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          venue.cuisine,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPriceLevelText(venue.priceLevel),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _RatingCard(
                rating: venue.rating,
                reviewCount: venue.reviewCount,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          if (venue.description.isNotEmpty) ...[
            Text(
              venue.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],

          // Status
          _StatusChip(isOpen: venue.isOpen),

          const SizedBox(height: 16),

          // Address and contact info
          _ContactInfoCard(venue: venue),

          const SizedBox(height: 16),

          // Opening hours
          _OpeningHoursCard(openingHours: venue.openingHours),

          const SizedBox(height: 16),

          // Amenities
          if (venue.amenities.isNotEmpty) ...[
            _AmenitiesSection(amenities: venue.amenities),
            const SizedBox(height: 16),
          ],

          // Categories
          if (venue.categories.isNotEmpty) ...[
            _CategoriesSection(categories: venue.categories),
          ],
        ],
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

class _RatingCard extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingCard({
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getRatingColor(rating).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRatingColor(rating).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 20,
                color: _getRatingColor(rating),
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getRatingColor(rating),
                ),
              ),
            ],
          ),
          if (reviewCount > 0) ...[
            const SizedBox(height: 2),
            Text(
              '$reviewCount отзывов',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOpen ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'Открыто' : 'Закрыто',
            style: TextStyle(
              color: isOpen ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final Venue venue;

  const _ContactInfoCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Контакты',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Address
            InkWell(
              onTap: () => _openMaps(venue.coordinates),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Адрес',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        Text(
                          venue.address.fullAddress,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            if (venue.distance != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    '${venue.distance!.toStringAsFixed(1)} км от вас',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openMaps(LatLng coordinates) async {
    final url =
        'https://yandex.ru/maps/?pt=${coordinates.longitude},${coordinates.latitude}&z=16';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class _OpeningHoursCard extends StatelessWidget {
  final OpeningHours openingHours;

  const _OpeningHoursCard({required this.openingHours});

  @override
  Widget build(BuildContext context) {
    if (openingHours.isOpen24Hours) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                'Круглосуточно',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    final dayNames = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 12),
                Text(
                  'Часы работы',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(days.length, (index) {
              final day = days[index];
              final dayName = dayNames[index];
              final dayHours = openingHours.hours[day];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      dayHours?.isClosed == true
                          ? 'Закрыто'
                          : dayHours?.openTime != null &&
                                  dayHours?.closeTime != null
                              ? '${dayHours!.openTime} - ${dayHours.closeTime}'
                              : 'Не указано',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dayHours?.isClosed == true
                                ? Colors.red[600]
                                : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  final List<Amenity> amenities;

  const _AmenitiesSection({required this.amenities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Удобства',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            return Chip(
              avatar: Icon(
                _getAmenityIcon(amenity.icon),
                size: 18,
              ),
              label: Text(amenity.name),
              backgroundColor: Colors.grey[100],
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case 'card':
        return Icons.credit_card;
      case 'terrace':
        return Icons.deck;
      case 'delivery':
        return Icons.delivery_dining;
      default:
        return Icons.check_circle;
    }
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<String> categories;

  const _CategoriesSection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Категории',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return Chip(
              label: Text(category),
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
