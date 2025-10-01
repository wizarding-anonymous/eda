import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/preorder_cart.dart';
import '../../providers/payment_provider.dart';
import '../../providers/preorder_provider.dart';
import '../../widgets/payment/payment_method_card.dart';
import '../../widgets/payment/order_summary_card.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;
  final String? reservationId;

  const PaymentMethodPage({
    super.key,
    required this.venueId,
    required this.venueName,
    this.reservationId,
  });

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(preorderCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Способ оплаты'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order Summary
                  OrderSummaryCard(
                    venueName: widget.venueName,
                    cart: cart,
                  ),

                  const SizedBox(height: 24),

                  // Payment Methods Section
                  Text(
                    'Выберите способ оплаты',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // СБП Payment Method
                  PaymentMethodCard(
                    method: PaymentMethod.sbp,
                    title: 'Система быстрых платежей',
                    subtitle: 'Оплата через банковское приложение',
                    icon: Icons.account_balance,
                    isSelected: _selectedMethod == PaymentMethod.sbp,
                    onTap: () => _selectPaymentMethod(PaymentMethod.sbp),
                  ),

                  const SizedBox(height: 12),

                  // Card Payment Method
                  PaymentMethodCard(
                    method: PaymentMethod.card,
                    title: 'Банковская карта',
                    subtitle: 'Мир, Visa, Mastercard',
                    icon: Icons.credit_card,
                    isSelected: _selectedMethod == PaymentMethod.card,
                    onTap: () => _selectPaymentMethod(PaymentMethod.card),
                  ),

                  const SizedBox(height: 24),

                  // Payment Info
                  _buildPaymentInfo(),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          _buildBottomAction(cart),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Информация об оплате',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            '• Предоплата за блюда списывается сразу',
          ),
          _buildInfoRow(
            '• Возврат средств невозможен после подтверждения',
          ),
          _buildInfoRow(
            '• При отмене заведением - полный возврат',
          ),
          _buildInfoRow(
            '• Безопасная оплата с шифрованием данных',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildBottomAction(PreorderCart cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'К оплате:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${cart.totalPrice.toStringAsFixed(0)} ₽',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMethod != null && !_isProcessing
                    ? () => _processPayment(cart)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _getPayButtonText(),
                        style: const TextStyle(
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

  String _getPayButtonText() {
    if (_selectedMethod == null) {
      return 'Выберите способ оплаты';
    }

    switch (_selectedMethod!) {
      case PaymentMethod.sbp:
        return 'Оплатить через СБП';
      case PaymentMethod.card:
        return 'Оплатить картой';
    }
  }

  void _selectPaymentMethod(PaymentMethod method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  Future<void> _processPayment(PreorderCart cart) async {
    if (_selectedMethod == null || cart.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create payment request
      final paymentRequest = PaymentRequest(
        orderId: 'preorder_${DateTime.now().millisecondsSinceEpoch}',
        amount: cart.totalPrice,
        method: _selectedMethod!,
      );

      // Process payment through provider
      final paymentProvider = ref.read(paymentNotifierProvider.notifier);
      final result = await paymentProvider.processPreorderPayment(
        paymentRequest,
        cart.toPreorderItems(),
        widget.venueId,
        widget.reservationId,
      );

      if (mounted) {
        if (result.isSuccess) {
          // Navigate to confirmation screen
          context.pushReplacementNamed(
            'booking_confirmation',
            pathParameters: {
              'venueId': widget.venueId,
            },
            queryParameters: {
              'venueName': widget.venueName,
              'transactionId': result.transactionId!,
              'hasPreorder': 'true',
            },
          );
        } else {
          // Show error
          _showPaymentError(result.errorMessage ?? 'Ошибка оплаты');
        }
      }
    } catch (e) {
      if (mounted) {
        _showPaymentError('Произошла ошибка при обработке платежа');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showPaymentError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка оплаты'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry payment
              _processPayment(ref.read(preorderCartProvider));
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
