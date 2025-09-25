import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String categoryId;
  final List<String> allergens;
  final List<MenuModifier> modifiers;
  final bool isAvailable;
  final int? preparationTime; // in minutes
  final NutritionalInfo? nutritionalInfo;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.allergens = const [],
    this.modifiers = const [],
    this.isAvailable = true,
    this.preparationTime,
    this.nutritionalInfo,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      categoryId: json['category_id'],
      allergens: List<String>.from(json['allergens'] ?? []),
      modifiers: (json['modifiers'] as List?)
              ?.map((modifier) => MenuModifier.fromJson(modifier))
              .toList() ??
          [],
      isAvailable: json['is_available'] ?? true,
      preparationTime: json['preparation_time'],
      nutritionalInfo: json['nutritional_info'] != null
          ? NutritionalInfo.fromJson(json['nutritional_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category_id': categoryId,
      'allergens': allergens,
      'modifiers': modifiers.map((modifier) => modifier.toJson()).toList(),
      'is_available': isAvailable,
      'preparation_time': preparationTime,
      'nutritional_info': nutritionalInfo?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        categoryId,
        allergens,
        modifiers,
        isAvailable,
        preparationTime,
        nutritionalInfo,
      ];
}

class MenuCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final List<MenuItem> items;

  const MenuCategory({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    this.items = const [],
  });

  @override
  List<Object?> get props => [id, name, description, sortOrder, items];
}

class MenuModifier extends Equatable {
  final String id;
  final String name;
  final double priceChange;
  final bool isRequired;
  final int maxSelections;

  const MenuModifier({
    required this.id,
    required this.name,
    required this.priceChange,
    this.isRequired = false,
    this.maxSelections = 1,
  });

  factory MenuModifier.fromJson(Map<String, dynamic> json) {
    return MenuModifier(
      id: json['id'],
      name: json['name'],
      priceChange: json['price_change'].toDouble(),
      isRequired: json['is_required'] ?? false,
      maxSelections: json['max_selections'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_change': priceChange,
      'is_required': isRequired,
      'max_selections': maxSelections,
    };
  }

  @override
  List<Object> get props => [id, name, priceChange, isRequired, maxSelections];
}

class NutritionalInfo extends Equatable {
  final int calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double fiber; // grams

  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }

  @override
  List<Object> get props => [calories, protein, carbs, fat, fiber];
}