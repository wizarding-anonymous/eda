import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/venue.dart';
import 'venue_card.dart';

class VenueListView extends ConsumerWidget {
  final List<Venue> venues;

  const VenueListView({
    super.key,
    required this.venues,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VenueCard(venue: venue),
        );
      },
    );
  }
}
