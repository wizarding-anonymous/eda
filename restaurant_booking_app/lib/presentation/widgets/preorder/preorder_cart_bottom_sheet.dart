import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/preorder_provider.dart';
import 'cart_item_tile.dart';

class PreorderCartBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onCheckout;

  const PreorderCartBottomSheet({
    super.key,
    required this.onCheckout,
  });

  @override
  ConsumerState<PreorderCartBottomSheet> createState() =>
      _PreorderCartBottomSheetState();
}

class _PreorderCartBottomSheetState
    extends ConsumerState<PreorderCartBottomSheet> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cart = ref.read(preorderCartProvider);
    _notesController.text = cart.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(preorderCartProvider);
    final cartNotifier = ref.read(preorderCartProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Корзина',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const Spacer(),
                    if (cart.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _showClearCartDialog(context, cartNotifier);
                        },
                        child: const Text('Очистить'),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Cart items
              Expanded(
                child: cart.isEmpty
                    ? _buildEmptyCart()
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:
                            cart.items.length + 1, // +1 for notes section
                        itemBuilder: (context, index) {
                          if (index == cart.items.length) {
                            return _buildNotesSection();
                          }

                          final item = cart.items[index];
                          return CartItemTile(
                            item: item,
                            onQuantityChanged: (quantity) {
                              cartNotifier.updateItemQuantity(index, quantity);
                            },
                            onRemove: () {
                              cartNotifier.removeItem(index);
                            },
                          );
                        },
                      ),
              ),

              // Footer with total and checkout button
              if (cart.isNotEmpty) _buildFooter(cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Корзина пуста',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте блюда из меню',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Комментарии к заказу',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Особые пожелания к заказу...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) {
              ref.read(preorderCartProvider.notifier).updateNotes(
                    value.isNotEmpty ? value : null,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Товаров: ${cart.totalItems}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${cart.totalPrice.toStringAsFixed(0)} ₽',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onCheckout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Оформить предзаказ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(
      BuildContext context, PreorderCartNotifier cartNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить корзину?'),
        content: const Text('Все добавленные блюда будут удалены из корзины.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              cartNotifier.clearCart();
              Navigator.of(context).pop();
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}
