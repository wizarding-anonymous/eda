import 'package:flutter/material.dart';

class MenuCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final TabController tabController;
  final Function(String) onCategorySelected;

  const MenuCategoryTabs({
    super.key,
    required this.categories,
    required this.tabController,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: (index) {
          if (index < categories.length) {
            onCategorySelected(categories[index]);
          }
        },
        tabs: categories.map((categoryId) {
          return Tab(
            text: _getCategoryDisplayName(categoryId),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryDisplayName(String categoryId) {
    // Map category IDs to display names
    // In a real app, this would come from a category repository
    final categoryNames = {
      'appetizers': 'Закуски',
      'soups': 'Супы',
      'main_courses': 'Основные блюда',
      'salads': 'Салаты',
      'desserts': 'Десерты',
      'beverages': 'Напитки',
      'hot_beverages': 'Горячие напитки',
      'alcohol': 'Алкоголь',
      'pizza': 'Пицца',
      'pasta': 'Паста',
      'sushi': 'Суши',
      'rolls': 'Роллы',
      'burgers': 'Бургеры',
      'steaks': 'Стейки',
      'seafood': 'Морепродукты',
      'vegetarian': 'Вегетарианское',
      'kids_menu': 'Детское меню',
    };

    return categoryNames[categoryId] ??
        categoryId.replaceAll('_', ' ').toUpperCase();
  }
}
