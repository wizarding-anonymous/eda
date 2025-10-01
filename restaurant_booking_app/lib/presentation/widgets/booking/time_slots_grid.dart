import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/time_slot.dart';

class TimeSlotsGrid extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final TimeSlot? selectedTimeSlot;
  final bool isLoading;
  final String? error;
  final Function(TimeSlot) onTimeSlotSelected;

  const TimeSlotsGrid({
    super.key,
    required this.timeSlots,
    required this.selectedTimeSlot,
    required this.isLoading,
    required this.error,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (error != null) {
      return _buildErrorState(context);
    }

    if (timeSlots.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildTimeSlotsGrid(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Загрузка доступного времени...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Ошибка загрузки',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Нет доступного времени',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'На выбранную дату и количество гостей нет свободных слотов. Попробуйте изменить параметры поиска.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsGrid(BuildContext context) {
    // Group time slots by time periods
    final groupedSlots = _groupTimeSlotsByPeriod(timeSlots);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time slots grid
        ...groupedSlots.entries.map((entry) => _buildTimeSlotGroup(
              context,
              entry.key,
              entry.value,
            )),

        const SizedBox(height: 12),

        // Legend
        _buildLegend(context),
      ],
    );
  }

  Widget _buildTimeSlotGroup(
      BuildContext context, String period, List<TimeSlot> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            period,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) =>
              _buildTimeSlotChip(context, slots[index]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimeSlotChip(BuildContext context, TimeSlot timeSlot) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(timeSlot.startTime);
    final endTime = timeFormat.format(timeSlot.endTime);
    final isSelected = selectedTimeSlot?.id == timeSlot.id;
    final isAvailable = timeSlot.isAvailable && !timeSlot.isPast;

    return Material(
      color: _getChipColor(context, isSelected, isAvailable),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isAvailable ? () => onTimeSlotSelected(timeSlot) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(context, isSelected, isAvailable),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$startTime-$endTime',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: _getTextColor(context, isSelected, isAvailable),
                ),
              ),
              if (timeSlot.availableCapacity < timeSlot.maxCapacity) ...[
                const SizedBox(height: 2),
                Text(
                  '${timeSlot.availableCapacity} мест',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getTextColor(context, isSelected, isAvailable)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (timeSlot.depositRequired != null &&
                  timeSlot.depositRequired! > 0) ...[
                const SizedBox(height: 2),
                Icon(
                  Icons.account_balance_wallet,
                  size: 10,
                  color: _getTextColor(context, isSelected, isAvailable)
                      .withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Обозначения:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(
                context,
                Icons.check_circle,
                'Доступно',
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                context,
                Icons.account_balance_wallet,
                'Требуется депозит',
                Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      BuildContext context, IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Map<String, List<TimeSlot>> _groupTimeSlotsByPeriod(List<TimeSlot> slots) {
    final groups = <String, List<TimeSlot>>{};

    for (final slot in slots) {
      final hour = slot.startTime.hour;
      String period;

      if (hour >= 6 && hour < 12) {
        period = 'Утро (06:00 - 12:00)';
      } else if (hour >= 12 && hour < 17) {
        period = 'День (12:00 - 17:00)';
      } else if (hour >= 17 && hour < 22) {
        period = 'Вечер (17:00 - 22:00)';
      } else {
        period = 'Ночь (22:00 - 06:00)';
      }

      groups.putIfAbsent(period, () => []).add(slot);
    }

    // Sort slots within each group by start time
    for (final group in groups.values) {
      group.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return groups;
  }

  Color _getChipColor(BuildContext context, bool isSelected, bool isAvailable) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primaryContainer;
    } else if (!isAvailable) {
      return Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5);
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  Color _getBorderColor(
      BuildContext context, bool isSelected, bool isAvailable) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    } else if (!isAvailable) {
      return Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
    } else {
      return Theme.of(context).colorScheme.outline.withValues(alpha: 0.5);
    }
  }

  Color _getTextColor(BuildContext context, bool isSelected, bool isAvailable) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    } else if (!isAvailable) {
      return Theme.of(context)
          .colorScheme
          .onSurfaceVariant
          .withValues(alpha: 0.5);
    } else {
      return Theme.of(context).colorScheme.onSurface;
    }
  }
}
