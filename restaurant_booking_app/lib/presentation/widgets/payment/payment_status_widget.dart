import 'package:flutter/material.dart';
import '../../../domain/services/preorder_payment_service.dart';

/// Widget that shows payment processing status with stages
class PaymentStatusWidget extends StatelessWidget {
  final PaymentStage currentStage;
  final bool isProcessing;
  final String? errorMessage;

  const PaymentStatusWidget({
    super.key,
    required this.currentStage,
    this.isProcessing = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProcessing ? Icons.hourglass_empty : Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Статус обработки',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStageIndicator(
              context, PaymentStage.validation, 'Проверка данных'),
          _buildStageIndicator(
              context, PaymentStage.payment, 'Обработка платежа'),
          _buildStageIndicator(
              context, PaymentStage.reservation, 'Создание бронирования'),
          _buildStageIndicator(context, PaymentStage.completed, 'Завершение'),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStageIndicator(
      BuildContext context, PaymentStage stage, String title) {
    final isCompleted = _isStageCompleted(stage);
    final isCurrent = currentStage == stage;
    final isError = errorMessage != null && isCurrent;

    Color iconColor;
    IconData iconData;

    if (isError) {
      iconColor = Colors.red.shade600;
      iconData = Icons.error;
    } else if (isCompleted) {
      iconColor = Colors.green.shade600;
      iconData = Icons.check_circle;
    } else if (isCurrent && isProcessing) {
      iconColor = Theme.of(context).colorScheme.primary;
      iconData = Icons.hourglass_empty;
    } else {
      iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
      iconData = Icons.radio_button_unchecked;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: isCurrent && isProcessing && !isError
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                : Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isError
                        ? Colors.red.shade700
                        : isCompleted
                            ? Colors.green.shade700
                            : isCurrent
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isStageCompleted(PaymentStage stage) {
    final stages = [
      PaymentStage.validation,
      PaymentStage.payment,
      PaymentStage.reservation,
      PaymentStage.completed,
    ];

    final currentIndex = stages.indexOf(currentStage);
    final stageIndex = stages.indexOf(stage);

    return currentIndex > stageIndex ||
        (currentStage == PaymentStage.completed &&
            stage == PaymentStage.completed);
  }
}

/// Overlay widget for showing payment processing
class PaymentProcessingOverlay extends StatelessWidget {
  final PaymentStage currentStage;
  final String? errorMessage;
  final VoidCallback? onCancel;

  const PaymentProcessingOverlay({
    super.key,
    required this.currentStage,
    this.errorMessage,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Обработка платежа',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              PaymentStatusWidget(
                currentStage: currentStage,
                isProcessing: errorMessage == null,
                errorMessage: errorMessage,
              ),
              const SizedBox(height: 24),
              if (errorMessage == null) ...[
                Text(
                  'Пожалуйста, не закрывайте приложение',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Отмена'),
                  ),
              ] else ...[
                Text(
                  'Произошла ошибка при обработке платежа',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Закрыть'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show payment processing overlay
  static Future<void> show(
    BuildContext context, {
    required PaymentStage currentStage,
    String? errorMessage,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentProcessingOverlay(
        currentStage: currentStage,
        errorMessage: errorMessage,
        onCancel: onCancel,
      ),
    );
  }
}

/// Compact payment status indicator for use in app bars or cards
class CompactPaymentStatusIndicator extends StatelessWidget {
  final PaymentStage currentStage;
  final bool isProcessing;

  const CompactPaymentStatusIndicator({
    super.key,
    required this.currentStage,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isProcessing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_getStatusColor(context)),
              ),
            )
          else
            Icon(
              _getStatusIcon(),
              size: 12,
              color: _getStatusColor(context),
            ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (currentStage) {
      case PaymentStage.validation:
        return Colors.orange.shade600;
      case PaymentStage.payment:
        return Colors.blue.shade600;
      case PaymentStage.reservation:
        return Colors.purple.shade600;
      case PaymentStage.completed:
        return Colors.green.shade600;
      case PaymentStage.unknown:
        return Colors.red.shade600;
    }
  }

  IconData _getStatusIcon() {
    switch (currentStage) {
      case PaymentStage.validation:
        return Icons.verified_user;
      case PaymentStage.payment:
        return Icons.payment;
      case PaymentStage.reservation:
        return Icons.event_available;
      case PaymentStage.completed:
        return Icons.check_circle;
      case PaymentStage.unknown:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (currentStage) {
      case PaymentStage.validation:
        return 'Проверка';
      case PaymentStage.payment:
        return 'Оплата';
      case PaymentStage.reservation:
        return 'Бронирование';
      case PaymentStage.completed:
        return 'Завершено';
      case PaymentStage.unknown:
        return 'Ошибка';
    }
  }
}
