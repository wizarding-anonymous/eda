import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectionWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;

  const DateSelectionWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.minDate,
    this.maxDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final effectiveMinDate = minDate ?? now;
    final effectiveMaxDate = maxDate ?? now.add(const Duration(days: 30));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick date selection buttons
        _buildQuickDateButtons(context, now),

        const SizedBox(height: 16),

        // Calendar picker button
        _buildCalendarButton(context, effectiveMinDate, effectiveMaxDate),

        if (selectedDate != null) ...[
          const SizedBox(height: 12),
          _buildSelectedDateDisplay(context),
        ],
      ],
    );
  }

  Widget _buildQuickDateButtons(BuildContext context, DateTime now) {
    final quickDates = [
      {'label': 'Сегодня', 'date': now},
      {'label': 'Завтра', 'date': now.add(const Duration(days: 1))},
      {'label': 'Послезавтра', 'date': now.add(const Duration(days: 2))},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickDates.map((dateInfo) {
        final date = dateInfo['date'] as DateTime;
        final label = dateInfo['label'] as String;
        final isSelected = selectedDate != null &&
            selectedDate!.year == date.year &&
            selectedDate!.month == date.month &&
            selectedDate!.day == date.day;

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onDateSelected(date),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildCalendarButton(
      BuildContext context, DateTime minDate, DateTime maxDate) {
    return OutlinedButton.icon(
      onPressed: () => _showDatePicker(context, minDate, maxDate),
      icon: const Icon(Icons.calendar_today),
      label: const Text('Выбрать другую дату'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSelectedDateDisplay(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'ru');
    final formattedDate = dateFormat.format(selectedDate!);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Выбрана дата: ${_capitalizeFirst(formattedDate)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(
      BuildContext context, DateTime minDate, DateTime maxDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? minDate,
      firstDate: minDate,
      lastDate: maxDate,
      locale: const Locale('ru'),
      helpText: 'Выберите дату бронирования',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
      fieldLabelText: 'Дата',
      fieldHintText: 'дд.мм.гггг',
      errorFormatText: 'Неверный формат даты',
      errorInvalidText: 'Дата вне допустимого диапазона',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: Theme.of(context).colorScheme.surface,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
