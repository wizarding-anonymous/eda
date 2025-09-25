import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
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
              onSubmitted: (query) {
                // TODO: Implement search
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Поиск: $query')),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Популярные категории',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _CategoryCard(
                    title: 'Итальянская',
                    icon: Icons.local_pizza,
                    onTap: () => _showCategory(context, 'Итальянская'),
                  ),
                  _CategoryCard(
                    title: 'Японская',
                    icon: Icons.ramen_dining,
                    onTap: () => _showCategory(context, 'Японская'),
                  ),
                  _CategoryCard(
                    title: 'Русская',
                    icon: Icons.restaurant,
                    onTap: () => _showCategory(context, 'Русская'),
                  ),
                  _CategoryCard(
                    title: 'Кафе',
                    icon: Icons.local_cafe,
                    onTap: () => _showCategory(context, 'Кафе'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to map view
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Карта (в разработке)')),
          );
        },
        child: const Icon(Icons.map),
      ),
    );
  }

  void _showCategory(BuildContext context, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Категория: $category (в разработке)')),
    );
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