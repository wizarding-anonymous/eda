import 'package:equatable/equatable.dart';

/// Represents a venue category for filtering and classification
class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? color; // Hex color code for UI theming
  final int sortOrder;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.color,
    required this.sortOrder,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        color,
        sortOrder,
        isActive,
      ];

  /// Creates a Category from JSON data
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converts Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (color != null) 'color': color,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  /// Creates a copy of this Category with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? color,
    int? sortOrder,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
