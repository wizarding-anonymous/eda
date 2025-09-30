import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/venue_search_provider.dart';
import '../../widgets/venue_search_bar.dart';
import '../../widgets/venue_filters_sheet.dart';
import '../../widgets/venue_list_view.dart';
import '../../widgets/venue_map_view.dart';

class VenuesSearchPage extends ConsumerWidget {
  const VenuesSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final showFilters = ref.watch(showFiltersProvider);
    final venuesAsync = ref.watch(venuesSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск заведений'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(showFiltersProvider.notifier).state = !showFilters;
            },
            icon: Icon(
              showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
          ),
          IconButton(
            onPressed: () {
              final newMode =
                  viewMode == ViewMode.list ? ViewMode.map : ViewMode.list;
              ref.read(viewModeProvider.notifier).state = newMode;
            },
            icon: Icon(
              viewMode == ViewMode.list ? Icons.map : Icons.list,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          const VenueSearchBar(),

          // Filters sheet
          if (showFilters) const VenueFiltersSheet(),

          // Content
          Expanded(
            child: venuesAsync.when(
              data: (venues) {
                if (venues.isEmpty) {
                  return const _EmptyState();
                }

                return viewMode == ViewMode.list
                    ? VenueListView(venues: venues)
                    : VenueMapView(venues: venues);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => _ErrorState(
                error: error.toString(),
                onRetry: () => ref.refresh(venuesSearchProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Заведения не найдены',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить параметры поиска',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
