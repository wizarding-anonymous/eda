import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/services/preorder_payment_service.dart';

/// Widget for handling payment results and showing appropriate UI
class PaymentResultHandler extends ConsumerWidget {
  final PreorderPaymentResult result;
  final String venueId;
  final String venueName;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const PaymentResultHandler({
    super.key,
    required this.result,
    required this.venueId,
    required this.venueName,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (result.isSuccess) {
      return _buildSuccessResult(context);
    } else {
      return _buildErrorResult(context);
    }
  }

  Widget _buildSuccessResult(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Оплата прошла успешно!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Предзаказ оплачен, бронирование подтверждено',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Перейти к подтверждению'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorResult(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка оплаты',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getErrorMessage(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getStageMessage(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red.shade500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Повторить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getErrorMessage() {
    return result.error ?? 'Произошла неизвестная ошибка';
  }

  String _getStageMessage() {
    switch (result.stage) {
      case PaymentStage.validation:
        return 'Ошибка валидации данных';
      case PaymentStage.payment:
        return 'Ошибка при обработке платежа';
      case PaymentStage.reservation:
        return 'Платеж прошел, но не удалось создать бронирование';
      case PaymentStage.completed:
        return 'Операция завершена успешно';
      case PaymentStage.unknown:
        return 'Неизвестная ошибка';
    }
  }

  void _navigateToConfirmation(BuildContext context) {
    if (result.paymentResult?.transactionId != null) {
      context.pushReplacementNamed(
        'booking_confirmation',
        pathParameters: {
          'venueId': venueId,
        },
        queryParameters: {
          'venueName': venueName,
          'transactionId': result.paymentResult!.transactionId!,
          'hasPreorder': 'true',
        },
      );
    }
  }
}

/// Dialog for showing payment results
class PaymentResultDialog extends StatelessWidget {
  final PreorderPaymentResult result;
  final String venueId;
  final String venueName;
  final VoidCallback? onRetry;

  const PaymentResultDialog({
    super.key,
    required this.result,
    required this.venueId,
    required this.venueName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: PaymentResultHandler(
        result: result,
        venueId: venueId,
        venueName: venueName,
        onRetry: () {
          Navigator.of(context).pop();
          onRetry?.call();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show payment result dialog
  static Future<void> show(
    BuildContext context, {
    required PreorderPaymentResult result,
    required String venueId,
    required String venueName,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentResultDialog(
        result: result,
        venueId: venueId,
        venueName: venueName,
        onRetry: onRetry,
      ),
    );
  }
}

/// Bottom sheet for showing payment results
class PaymentResultBottomSheet extends StatelessWidget {
  final PreorderPaymentResult result;
  final String venueId;
  final String venueName;
  final VoidCallback? onRetry;

  const PaymentResultBottomSheet({
    super.key,
    required this.result,
    required this.venueId,
    required this.venueName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: PaymentResultHandler(
          result: result,
          venueId: venueId,
          venueName: venueName,
          onRetry: () {
            Navigator.of(context).pop();
            onRetry?.call();
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Show payment result bottom sheet
  static Future<void> show(
    BuildContext context, {
    required PreorderPaymentResult result,
    required String venueId,
    required String venueName,
    VoidCallback? onRetry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PaymentResultBottomSheet(
        result: result,
        venueId: venueId,
        venueName: venueName,
        onRetry: onRetry,
      ),
    );
  }
}
