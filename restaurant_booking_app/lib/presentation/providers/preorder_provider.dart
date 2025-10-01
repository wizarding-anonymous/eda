import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/preorder_cart.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../core/di/injection.dart';

/// Provider for managing preorder cart state
final preorderCartProvider =
    StateNotifierProvider<PreorderCartNotifier, PreorderCart>((ref) {
  return PreorderCartNotifier();
});

/// Provider for fetching venue menu
final venueMenuProvider =
    FutureProvider.family<List<MenuItem>, String>((ref, venueId) async {
  final repository = getIt<VenueRepository>();
  final result = await repository.getVenueMenu(venueId);

  return result.when(
    success: (menu) => menu,
    failure: (error) => throw Exception(error.message),
  );
});

/// Provider for grouped menu items by category
final groupedMenuProvider =
    Provider.family<Map<String, List<MenuItem>>, List<MenuItem>>(
        (ref, menuItems) {
  final Map<String, List<MenuItem>> grouped = {};

  for (final item in menuItems) {
    if (!grouped.containsKey(item.categoryId)) {
      grouped[item.categoryId] = [];
    }
    grouped[item.categoryId]!.add(item);
  }

  return grouped;
});

class PreorderCartNotifier extends StateNotifier<PreorderCart> {
  PreorderCartNotifier() : super(const PreorderCart());

  /// Add item to cart
  void addItem({
    required MenuItem menuItem,
    int quantity = 1,
    List<MenuModifier> selectedModifiers = const [],
    String? notes,
  }) {
    final cartItem = PreorderCartItem(
      menuItem: menuItem,
      quantity: quantity,
      selectedModifiers: selectedModifiers,
      notes: notes,
    );

    state = state.addItem(cartItem);
  }

  /// Update item quantity
  void updateItemQuantity(int index, int quantity) {
    state = state.updateItemQuantity(index, quantity);
  }

  /// Remove item from cart
  void removeItem(int index) {
    state = state.removeItem(index);
  }

  /// Clear cart
  void clearCart() {
    state = state.clear();
  }

  /// Update cart notes
  void updateNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  /// Get item count for specific menu item
  int getItemCount(String menuItemId) {
    return state.items
        .where((item) => item.menuItem.id == menuItemId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if menu item is in cart
  bool isItemInCart(String menuItemId) {
    return state.items.any((item) => item.menuItem.id == menuItemId);
  }
}

/// State for preorder screen
class PreorderScreenState {
  final bool isLoading;
  final String? error;
  final List<MenuItem> menuItems;
  final Map<String, List<MenuItem>> groupedMenu;
  final String? selectedCategoryId;

  const PreorderScreenState({
    this.isLoading = false,
    this.error,
    this.menuItems = const [],
    this.groupedMenu = const {},
    this.selectedCategoryId,
  });

  PreorderScreenState copyWith({
    bool? isLoading,
    String? error,
    List<MenuItem>? menuItems,
    Map<String, List<MenuItem>>? groupedMenu,
    String? selectedCategoryId,
  }) {
    return PreorderScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      menuItems: menuItems ?? this.menuItems,
      groupedMenu: groupedMenu ?? this.groupedMenu,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

/// Provider for preorder screen state
final preorderScreenProvider = StateNotifierProvider.family<
    PreorderScreenNotifier, PreorderScreenState, String>((ref, venueId) {
  return PreorderScreenNotifier(venueId, ref);
});

class PreorderScreenNotifier extends StateNotifier<PreorderScreenState> {
  final String venueId;
  final Ref ref;

  PreorderScreenNotifier(this.venueId, this.ref)
      : super(const PreorderScreenState()) {
    loadMenu();
  }

  Future<void> loadMenu() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final menuItems = await ref.read(venueMenuProvider(venueId).future);
      final groupedMenu = ref.read(groupedMenuProvider(menuItems));

      state = state.copyWith(
        isLoading: false,
        menuItems: menuItems,
        groupedMenu: groupedMenu,
        selectedCategoryId:
            groupedMenu.keys.isNotEmpty ? groupedMenu.keys.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void retry() {
    loadMenu();
  }
}
