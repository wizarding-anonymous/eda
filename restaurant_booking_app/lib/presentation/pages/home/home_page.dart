import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/venue_search_provider.dart';
import '../../../domain/entities/venue.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Booking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authState.user != null) ...[
              Text(
                'Привет, ${authState.user!.name}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Рейтинг: ${authState.user!.rating.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],
            TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск ресторанов',
                hintText: 'Название, кухня, район...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onTap: () {
                context.push('/venues/search');
              },
              readOnly: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Популярные категории',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                      title: category.name,
                      icon: _getCategoryIcon(category.name),
                      onTap: () => _showCategory(context, ref, category),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки категорий',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(categoriesProvider),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/venues/search');
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  void _showCategory(BuildContext context, WidgetRef ref, category) {
    // Set the selected category and navigate to search
    ref.read(selectedCategoryProvider.notifier).state = category;
    ref.read(searchFiltersProvider.notifier).state =
        const SearchFilters().copyWith(categories: [category.id]);
    context.push('/venues/search');
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'итальянская':
      case 'italian':
        return Icons.local_pizza;
      case 'японская':
      case 'japanese':
        return Icons.ramen_dining;
      case 'русская':
      case 'russian':
        return Icons.restaurant;
      case 'кафе':
      case 'cafe':
        return Icons.local_cafe;
      case 'фастфуд':
      case 'fast food':
        return Icons.fastfood;
      case 'бар':
      case 'bar':
        return Icons.local_bar;
      default:
        return Icons.restaurant_menu;
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
