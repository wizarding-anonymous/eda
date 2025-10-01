import 'package:flutter/material.dart';
import '../../../domain/entities/payment.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEnabled;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Payment method info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isEnabled
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isEnabled
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodSection extends StatelessWidget {
  final String title;
  final List<PaymentMethodCard> methods;

  const PaymentMethodSection({
    super.key,
    required this.title,
    required this.methods,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...methods.map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: method,
            )),
      ],
    );
  }
}

class PaymentMethodIcon extends StatelessWidget {
  final PaymentMethod method;
  final double size;

  const PaymentMethodIcon({
    super.key,
    required this.method,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color? iconColor;

    switch (method) {
      case PaymentMethod.sbp:
        iconData = Icons.account_balance;
        iconColor = Colors.blue;
        break;
      case PaymentMethod.card:
        iconData = Icons.credit_card;
        iconColor = Colors.green;
        break;
    }

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }
}

class PaymentMethodChip extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaymentMethodChip({
    super.key,
    required this.method,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String label;
    IconData icon;

    switch (method) {
      case PaymentMethod.sbp:
        label = 'СБП';
        icon = Icons.account_balance;
        break;
      case PaymentMethod.card:
        label = 'Карта';
        icon = Icons.credit_card;
        break;
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.secondaryContainer,
      checkmarkColor: colorScheme.onSecondaryContainer,
      side: BorderSide(
        color: isSelected
            ? colorScheme.secondary
            : colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }
}
