import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/venue_search_provider.dart';
import '../../domain/entities/venue.dart';
import '../../domain/entities/category.dart';

class VenueFiltersSheet extends ConsumerWidget {
  const VenueFiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Фильтры',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(searchFiltersProvider.notifier).state =
                        const SearchFilters();
                  },
                  child: const Text('Сбросить'),
                ),
              ],
            ),
          ),

          // Categories
          categoriesAsync.when(
            data: (categories) => _CategoriesFilter(
              categories: categories,
              selectedCategories: filters.categories,
              onCategoriesChanged: (selected) {
                ref.read(searchFiltersProvider.notifier).state =
                    filters.copyWith(categories: selected);
              },
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Distance filter
          _DistanceFilter(
            maxDistance: filters.maxDistance,
            onDistanceChanged: (distance) {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(maxDistance: distance);
            },
          ),

          // Price level filter
          _PriceLevelFilter(
            priceLevel: filters.priceLevel,
            onPriceLevelChanged: (priceLevel) {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(priceLevel: priceLevel);
            },
          ),

          // Open now toggle
          _OpenNowFilter(
            openNow: filters.openNow,
            onOpenNowChanged: (openNow) {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(openNow: openNow);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CategoriesFilter extends StatelessWidget {
  final List<Category> categories;
  final List<String> selectedCategories;
  final ValueChanged<List<String>> onCategoriesChanged;

  const _CategoriesFilter({
    required this.categories,
    required this.selectedCategories,
    required this.onCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Категории',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategories.contains(category.id);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newSelection = List<String>.from(selectedCategories);
                    if (selected) {
                      newSelection.add(category.id);
                    } else {
                      newSelection.remove(category.id);
                    }
                    onCategoriesChanged(newSelection);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DistanceFilter extends StatelessWidget {
  final double? maxDistance;
  final ValueChanged<double?> onDistanceChanged;

  const _DistanceFilter({
    required this.maxDistance,
    required this.onDistanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Расстояние: ${maxDistance?.toStringAsFixed(1) ?? 'Любое'} км',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: maxDistance ?? 10.0,
            min: 0.5,
            max: 50.0,
            divisions: 99,
            onChanged: onDistanceChanged,
          ),
        ],
      ),
    );
  }
}

class _PriceLevelFilter extends StatelessWidget {
  final PriceLevel? priceLevel;
  final ValueChanged<PriceLevel?> onPriceLevelChanged;

  const _PriceLevelFilter({
    required this.priceLevel,
    required this.onPriceLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ценовая категория',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Любая'),
                selected: priceLevel == null,
                onSelected: (selected) {
                  if (selected) onPriceLevelChanged(null);
                },
              ),
              ...PriceLevel.values.map((level) {
                return FilterChip(
                  label: Text(_getPriceLevelText(level)),
                  selected: priceLevel == level,
                  onSelected: (selected) {
                    onPriceLevelChanged(selected ? level : null);
                  },
                );
              }),
            ],
          ),
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

class _OpenNowFilter extends StatelessWidget {
  final bool openNow;
  final ValueChanged<bool> onOpenNowChanged;

  const _OpenNowFilter({
    required this.openNow,
    required this.onOpenNowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Открыто сейчас',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Switch(
            value: openNow,
            onChanged: onOpenNowChanged,
          ),
        ],
      ),
    );
  }
}
