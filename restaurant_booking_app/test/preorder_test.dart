import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/menu.dart';
import 'package:restaurant_booking_app/domain/entities/preorder_cart.dart';

void main() {
  group('Preorder System Tests', () {
    late MenuItem testMenuItem;
    late MenuModifier testModifier;

    setUp(() {
      testModifier = const MenuModifier(
        id: 'mod1',
        name: 'Extra Cheese',
        priceChange: 50.0,
      );

      testMenuItem = MenuItem(
        id: 'item1',
        name: 'Pizza Margherita',
        description: 'Classic pizza with tomato and mozzarella',
        price: 450.0,
        categoryId: 'pizza',
        modifiers: [testModifier],
      );
    });

    group('PreorderCartItem', () {
      test('should calculate total price correctly without modifiers', () {
        final cartItem = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 2,
        );

        expect(cartItem.totalPrice, equals(900.0)); // 450 * 2
      });

      test('should calculate total price correctly with modifiers', () {
        final cartItem = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 2,
          selectedModifiers: [testModifier],
        );

        expect(cartItem.totalPrice, equals(1000.0)); // (450 + 50) * 2
      });

      test('should convert to PreorderItem correctly', () {
        final cartItem = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 2,
          selectedModifiers: [testModifier],
          notes: 'Extra crispy',
        );

        final preorderItem = cartItem.toPreorderItem();

        expect(preorderItem.menuItemId, equals('item1'));
        expect(preorderItem.name, equals('Pizza Margherita'));
        expect(preorderItem.quantity, equals(2));
        expect(preorderItem.price, equals(450.0));
        expect(preorderItem.notes, equals('Extra crispy'));
        expect(preorderItem.modifiers, equals(['mod1']));
      });
    });

    group('PreorderCart', () {
      test('should start empty', () {
        const cart = PreorderCart();

        expect(cart.isEmpty, isTrue);
        expect(cart.isNotEmpty, isFalse);
        expect(cart.totalItems, equals(0));
        expect(cart.totalPrice, equals(0.0));
      });

      test('should add items correctly', () {
        const cart = PreorderCart();
        final cartItem = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 2,
        );

        final updatedCart = cart.addItem(cartItem);

        expect(updatedCart.items.length, equals(1));
        expect(updatedCart.totalItems, equals(2));
        expect(updatedCart.totalPrice, equals(900.0));
      });

      test('should update quantity when adding same item', () {
        const cart = PreorderCart();
        final cartItem1 = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 1,
        );
        final cartItem2 = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 2,
        );

        final updatedCart = cart.addItem(cartItem1).addItem(cartItem2);

        expect(updatedCart.items.length, equals(1));
        expect(updatedCart.totalItems, equals(3));
        expect(updatedCart.totalPrice, equals(1350.0)); // 450 * 3
      });

      test('should treat items with different modifiers as separate', () {
        const cart = PreorderCart();
        final cartItem1 = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 1,
        );
        final cartItem2 = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 1,
          selectedModifiers: [testModifier],
        );

        final updatedCart = cart.addItem(cartItem1).addItem(cartItem2);

        expect(updatedCart.items.length, equals(2));
        expect(updatedCart.totalItems, equals(2));
        expect(updatedCart.totalPrice, equals(950.0)); // 450 + (450 + 50)
      });

      test('should update item quantity correctly', () {
        const cart = PreorderCart();
        final cartItem = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 1,
        );

        final updatedCart = cart.addItem(cartItem).updateItemQuantity(0, 3);

        expect(updatedCart.items.length, equals(1));
        expect(updatedCart.totalItems, equals(3));
        expect(updatedCart.totalPrice, equals(1350.0));
      });

      test('should remove item when quantity is set to 0', () {
        const cart = PreorderCart();
        final cartItem = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 1,
        );

        final updatedCart = cart.addItem(cartItem).updateItemQuantity(0, 0);

        expect(updatedCart.isEmpty, isTrue);
      });

      test('should remove item correctly', () {
        const cart = PreorderCart();
        final cartItem1 = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 1,
        );
        final cartItem2 = PreorderCartItem(
          menuItem: testMenuItem.copyWith(id: 'item2'),
          quantity: 2,
        );

        final updatedCart =
            cart.addItem(cartItem1).addItem(cartItem2).removeItem(0);

        expect(updatedCart.items.length, equals(1));
        expect(updatedCart.items.first.menuItem.id, equals('item2'));
      });

      test('should clear all items', () {
        const cart = PreorderCart();
        final cartItem = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 2,
        );

        final updatedCart = cart.addItem(cartItem).clear();

        expect(updatedCart.isEmpty, isTrue);
      });

      test('should convert to preorder items correctly', () {
        const cart = PreorderCart();
        final cartItem1 = PreorderCartItem(
          menuItem: testMenuItem,
          quantity: 1,
        );
        final cartItem2 = PreorderCartItem(
          menuItem: testMenuItem.copyWith(id: 'item2', name: 'Pizza Pepperoni'),
          quantity: 2,
          selectedModifiers: [testModifier],
        );

        final updatedCart = cart.addItem(cartItem1).addItem(cartItem2);
        final preorderItems = updatedCart.toPreorderItems();

        expect(preorderItems.length, equals(2));
        expect(preorderItems[0].menuItemId, equals('item1'));
        expect(preorderItems[0].quantity, equals(1));
        expect(preorderItems[1].menuItemId, equals('item2'));
        expect(preorderItems[1].quantity, equals(2));
        expect(preorderItems[1].modifiers, equals(['mod1']));
      });
    });
  });
}

extension MenuItemCopyWith on MenuItem {
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    List<String>? allergens,
    List<MenuModifier>? modifiers,
    bool? isAvailable,
    int? preparationTime,
    NutritionalInfo? nutritionalInfo,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      allergens: allergens ?? this.allergens,
      modifiers: modifiers ?? this.modifiers,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTime: preparationTime ?? this.preparationTime,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
    );
  }
}
