import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/menu.dart';
import '../providers/venue_details_provider.dart';

class VenueMenuSection extends ConsumerWidget {
  final String venueId;

  const VenueMenuSection({
    super.key,
    required this.venueId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(venueMenuProvider(venueId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Меню',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => _showFullMenu(context, ref),
                  child: const Text('Показать всё'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            menuAsync.when(
              data: (menuItems) {
                if (menuItems.isEmpty) {
                  return const _EmptyMenuState();
                }

                // Group menu items by category
                final groupedItems = _groupMenuItemsByCategory(menuItems);

                // Show only first few items from each category
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groupedItems.entries.take(2).map((entry) {
                    final categoryId = entry.key;
                    final items = entry.value.take(3).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (categoryId.isNotEmpty) ...[
                          Text(
                            _getCategoryName(categoryId),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        ...items.map((item) => _MenuItemTile(item: item)),
                        if (entry.value.length > 3) ...[
                          const SizedBox(height: 8),
                          Text(
                            'и ещё ${entry.value.length - 3} блюд...',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _ErrorMenuState(
                error: error.toString(),
                onRetry: () => ref.refresh(venueMenuProvider(venueId)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<MenuItem>> _groupMenuItemsByCategory(List<MenuItem> items) {
    final Map<String, List<MenuItem>> grouped = {};

    for (final item in items) {
      if (!grouped.containsKey(item.categoryId)) {
        grouped[item.categoryId] = [];
      }
      grouped[item.categoryId]!.add(item);
    }

    return grouped;
  }

  String _getCategoryName(String categoryId) {
    // This would normally come from a categories lookup
    // For now, return a formatted version of the ID
    switch (categoryId.toLowerCase()) {
      case 'appetizers':
        return 'Закуски';
      case 'main_courses':
        return 'Основные блюда';
      case 'desserts':
        return 'Десерты';
      case 'beverages':
        return 'Напитки';
      case 'salads':
        return 'Салаты';
      case 'soups':
        return 'Супы';
      default:
        return categoryId;
    }
  }

  void _showFullMenu(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullMenuPage(venueId: venueId),
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItem item;

  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  );
                },
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, color: Colors.grey),
            ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item.price.toStringAsFixed(0)} ₽',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (!item.isAvailable) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Временно недоступно',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Меню пока не загружено',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMenuState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorMenuState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки меню',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
    );
  }
}

class _FullMenuPage extends ConsumerWidget {
  final String venueId;

  const _FullMenuPage({required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(venueMenuProvider(venueId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Меню'),
      ),
      body: menuAsync.when(
        data: (menuItems) {
          if (menuItems.isEmpty) {
            return const Center(child: _EmptyMenuState());
          }

          final groupedItems = _groupMenuItemsByCategory(menuItems);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedItems.length,
            itemBuilder: (context, index) {
              final entry = groupedItems.entries.elementAt(index);
              final categoryId = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryId.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _getCategoryName(categoryId),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                  ...items.map((item) => _MenuItemTile(item: item)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: _ErrorMenuState(
            error: error.toString(),
            onRetry: () => ref.refresh(venueMenuProvider(venueId)),
          ),
        ),
      ),
    );
  }

  Map<String, List<MenuItem>> _groupMenuItemsByCategory(List<MenuItem> items) {
    final Map<String, List<MenuItem>> grouped = {};

    for (final item in items) {
      if (!grouped.containsKey(item.categoryId)) {
        grouped[item.categoryId] = [];
      }
      grouped[item.categoryId]!.add(item);
    }

    return grouped;
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'appetizers':
        return 'Закуски';
      case 'main_courses':
        return 'Основные блюда';
      case 'desserts':
        return 'Десерты';
      case 'beverages':
        return 'Напитки';
      case 'salads':
        return 'Салаты';
      case 'soups':
        return 'Супы';
      default:
        return categoryId;
    }
  }
}
