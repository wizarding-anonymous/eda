import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/payment_provider.dart';
import '../../providers/booking_form_provider.dart';
import '../../providers/preorder_provider.dart';
import '../../widgets/payment/order_summary_card.dart';

class BookingConfirmationPage extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;
  final String transactionId;
  final bool hasPreorder;

  const BookingConfirmationPage({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.transactionId,
    this.hasPreorder = false,
  });

  @override
  ConsumerState<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState
    extends ConsumerState<BookingConfirmationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // Clear cart after successful booking
    if (widget.hasPreorder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(preorderCartProvider.notifier).clearCart();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingForm = ref.watch(bookingFormProvider);
    final cart = ref.watch(preorderCartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green.shade600,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Success Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Бронирование подтверждено!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (widget.hasPreorder)
                      Text(
                        'Предзаказ оплачен успешно',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Booking Details Card
              _buildBookingDetailsCard(bookingForm),

              const SizedBox(height: 16),

              // Preorder Summary (if applicable)
              if (widget.hasPreorder && cart.isNotEmpty)
                OrderSummaryCard(
                  venueName: widget.venueName,
                  cart: cart,
                  showDetails: false,
                ),

              const SizedBox(height: 16),

              // Transaction Details
              _buildTransactionCard(),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(BookingFormState bookingForm) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ru');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_available,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Детали бронирования',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Заведение:',
              widget.venueName,
              Icons.restaurant,
            ),
            if (bookingForm.selectedDate != null)
              _buildDetailRow(
                'Дата:',
                dateFormat.format(bookingForm.selectedDate!),
                Icons.calendar_today,
              ),
            if (bookingForm.selectedTimeSlot != null)
              _buildDetailRow(
                'Время:',
                '${timeFormat.format(bookingForm.selectedTimeSlot!.startTime)} - ${timeFormat.format(bookingForm.selectedTimeSlot!.endTime)}',
                Icons.access_time,
              ),
            if (bookingForm.partySize != null)
              _buildDetailRow(
                'Гостей:',
                '${bookingForm.partySize} ${_getGuestWord(bookingForm.partySize!)}',
                Icons.people,
              ),
            if (bookingForm.selectedTableType != null)
              _buildDetailRow(
                'Тип столика:',
                bookingForm.selectedTableType!.displayName,
                Icons.table_restaurant,
              ),
            if (bookingForm.notes?.isNotEmpty == true)
              _buildDetailRow(
                'Комментарии:',
                bookingForm.notes!,
                Icons.note,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Информация о платеже',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'ID транзакции:',
              widget.transactionId,
              Icons.confirmation_number,
            ),
            _buildDetailRow(
              'Статус:',
              'Оплачено',
              Icons.check_circle,
            ),
            _buildDetailRow(
              'Время:',
              DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _navigateToHome(),
          icon: const Icon(Icons.home),
          label: const Text('На главную'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewBookingHistory(),
                icon: const Icon(Icons.history),
                label: const Text('Мои брони'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _getReceipt(),
                icon: const Icon(Icons.download),
                label: const Text('Чек'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGuestWord(int count) {
    if (count == 1) return 'гость';
    if (count >= 2 && count <= 4) return 'гостя';
    return 'гостей';
  }

  void _navigateToHome() {
    context.goNamed('home');
  }

  void _viewBookingHistory() {
    context.pushNamed('booking_history');
  }

  Future<void> _getReceipt() async {
    try {
      final paymentProvider = ref.read(paymentNotifierProvider.notifier);
      final receipt = await paymentProvider.getReceipt(widget.transactionId);

      if (receipt != null && mounted) {
        // Show receipt or download it
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Чек будет отправлен на вашу электронную почту'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось получить чек'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
