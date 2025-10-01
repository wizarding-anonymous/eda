import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/preorder_provider.dart';
import '../../widgets/preorder/menu_category_tabs.dart';
import '../../widgets/preorder/menu_item_card.dart';
import '../../widgets/preorder/preorder_cart_bottom_sheet.dart';
import '../../widgets/preorder/preorder_cart_fab.dart';
import '../../../domain/entities/menu.dart';

class PreorderPage extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;

  const PreorderPage({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  ConsumerState<PreorderPage> createState() => _PreorderPageState();
}

class _PreorderPageState extends ConsumerState<PreorderPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(preorderScreenProvider(widget.venueId));
    final cartState = ref.watch(preorderCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предзаказ'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.venueName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(screenState),
      floatingActionButton: cartState.isNotEmpty
          ? PreorderCartFab(
              itemCount: cartState.totalItems,
              totalPrice: cartState.totalPrice,
              onPressed: () => _showCartBottomSheet(context),
            )
          : null,
    );
  }

  Widget _buildBody(PreorderScreenState screenState) {
    if (screenState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (screenState.error != null) {
      return _buildErrorState(screenState.error!);
    }

    if (screenState.menuItems.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMenuContent(screenState);
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки меню',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(preorderScreenProvider(widget.venueId).notifier)
                    .retry();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Меню пока недоступно',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Заведение еще не загрузило свое меню',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent(PreorderScreenState screenState) {
    final categories = screenState.groupedMenu.keys.toList();

    // Initialize tab controller if not already done
    if (_tabController == null || _tabController!.length != categories.length) {
      _tabController?.dispose();
      _tabController = TabController(
        length: categories.length,
        vsync: this,
      );
    }

    return Column(
      children: [
        // Category tabs
        if (categories.length > 1)
          MenuCategoryTabs(
            categories: categories,
            tabController: _tabController!,
            onCategorySelected: (categoryId) {
              ref
                  .read(preorderScreenProvider(widget.venueId).notifier)
                  .selectCategory(categoryId);
            },
          ),

        // Menu items
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories.map((categoryId) {
              final items = screenState.groupedMenu[categoryId] ?? [];
              return _buildMenuItemsList(items);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemsList(List<MenuItem> items) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MenuItemCard(
            menuItem: item,
            onAddToCart: (menuItem, quantity, modifiers, notes) {
              ref.read(preorderCartProvider.notifier).addItem(
                    menuItem: menuItem,
                    quantity: quantity,
                    selectedModifiers: modifiers,
                    notes: notes,
                  );

              // Show snackbar confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${menuItem.name} добавлен в корзину'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PreorderCartBottomSheet(
        onCheckout: () {
          Navigator.of(context).pop();
          _proceedToCheckout();
        },
      ),
    );
  }

  void _proceedToCheckout() {
    final cart = ref.read(preorderCartProvider);
    if (cart.isEmpty) return;

    // Navigate to payment method selection
    context.pushNamed(
      'payment_method',
      pathParameters: {
        'venueId': widget.venueId,
      },
      queryParameters: {
        'venueName': widget.venueName,
      },
    );
  }
}
