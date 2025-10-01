import 'package:equatable/equatable.dart';
import 'menu.dart';
import 'reservation.dart';

/// Represents an item in the preorder cart with selected modifiers
class PreorderCartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;
  final List<MenuModifier> selectedModifiers;
  final String? notes;

  const PreorderCartItem({
    required this.menuItem,
    required this.quantity,
    this.selectedModifiers = const [],
    this.notes,
  });

  /// Calculate the total price including modifiers
  double get totalPrice {
    final modifierPrice = selectedModifiers.fold<double>(
      0.0,
      (sum, modifier) => sum + modifier.priceChange,
    );
    return (menuItem.price + modifierPrice) * quantity;
  }

  /// Convert to PreorderItem for API
  PreorderItem toPreorderItem() {
    return PreorderItem(
      menuItemId: menuItem.id,
      name: menuItem.name,
      quantity: quantity,
      price: menuItem.price,
      notes: notes,
      modifiers: selectedModifiers.map((m) => m.id).toList(),
    );
  }

  PreorderCartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    List<MenuModifier>? selectedModifiers,
    String? notes,
  }) {
    return PreorderCartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        menuItem,
        quantity,
        selectedModifiers,
        notes,
      ];
}

/// Represents the preorder cart state
class PreorderCart extends Equatable {
  final List<PreorderCartItem> items;
  final String? notes;

  const PreorderCart({
    this.items = const [],
    this.notes,
  });

  /// Calculate total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Calculate total price
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Add item to cart or update quantity if already exists
  PreorderCart addItem(PreorderCartItem item) {
    final existingIndex = items.indexWhere(
      (cartItem) =>
          cartItem.menuItem.id == item.menuItem.id &&
          _areModifiersEqual(
              cartItem.selectedModifiers, item.selectedModifiers),
    );

    if (existingIndex >= 0) {
      // Update existing item quantity
      final updatedItems = List<PreorderCartItem>.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
      return copyWith(items: updatedItems);
    } else {
      // Add new item
      return copyWith(items: [...items, item]);
    }
  }

  /// Update item quantity
  PreorderCart updateItemQuantity(int index, int quantity) {
    if (index < 0 || index >= items.length) return this;

    if (quantity <= 0) {
      return removeItem(index);
    }

    final updatedItems = List<PreorderCartItem>.from(items);
    updatedItems[index] = updatedItems[index].copyWith(quantity: quantity);
    return copyWith(items: updatedItems);
  }

  /// Remove item from cart
  PreorderCart removeItem(int index) {
    if (index < 0 || index >= items.length) return this;

    final updatedItems = List<PreorderCartItem>.from(items);
    updatedItems.removeAt(index);
    return copyWith(items: updatedItems);
  }

  /// Clear all items from cart
  PreorderCart clear() {
    return const PreorderCart();
  }

  /// Convert to list of PreorderItems for API
  List<PreorderItem> toPreorderItems() {
    return items.map((item) => item.toPreorderItem()).toList();
  }

  PreorderCart copyWith({
    List<PreorderCartItem>? items,
    String? notes,
  }) {
    return PreorderCart(
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }

  /// Helper method to compare modifier lists
  bool _areModifiersEqual(List<MenuModifier> list1, List<MenuModifier> list2) {
    if (list1.length != list2.length) return false;

    final ids1 = list1.map((m) => m.id).toSet();
    final ids2 = list2.map((m) => m.id).toSet();

    return ids1.containsAll(ids2) && ids2.containsAll(ids1);
  }

  @override
  List<Object?> get props => [items, notes];
}
