import 'package:flutter/material.dart';

class PartySizeSelector extends StatelessWidget {
  final int? selectedSize;
  final Function(int) onSizeSelected;
  final int minSize;
  final int maxSize;

  const PartySizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeSelected,
    this.minSize = 1,
    this.maxSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick selection buttons for common party sizes
        _buildQuickSizeButtons(context),

        const SizedBox(height: 16),

        // Custom size input
        _buildCustomSizeInput(context),

        if (selectedSize != null) ...[
          const SizedBox(height: 12),
          _buildSelectedSizeDisplay(context),
        ],
      ],
    );
  }

  Widget _buildQuickSizeButtons(BuildContext context) {
    final quickSizes = [1, 2, 3, 4, 5, 6, 8, 10];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickSizes.map((size) {
        final isSelected = selectedSize == size;

        return FilterChip(
          label: Text('$size ${_getGuestWord(size)}'),
          selected: isSelected,
          onSelected: (_) => onSizeSelected(size),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildCustomSizeInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Другое количество',
              hintText: 'Введите количество гостей',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.people),
              suffixText: 'чел.',
            ),
            onChanged: (value) {
              final size = int.tryParse(value);
              if (size != null && size >= minSize && size <= maxSize) {
                onSizeSelected(size);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) return null;

              final size = int.tryParse(value);
              if (size == null) {
                return 'Введите число';
              }

              if (size < minSize || size > maxSize) {
                return 'От $minSize до $maxSize гостей';
              }

              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        IconButton.outlined(
          onPressed: () => _showPartySizeDialog(context),
          icon: const Icon(Icons.help_outline),
          tooltip: 'Помощь в выборе',
        ),
      ],
    );
  }

  Widget _buildSelectedSizeDisplay(BuildContext context) {
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
            'Выбрано: $selectedSize ${_getGuestWord(selectedSize!)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getGuestWord(int count) {
    if (count == 1) return 'гость';
    if (count >= 2 && count <= 4) return 'гостя';
    return 'гостей';
  }

  Future<void> _showPartySizeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выбор количества гостей'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Рекомендации по выбору:'),
            SizedBox(height: 8),
            Text('• 1-2 гостя: столик для двоих'),
            Text('• 3-4 гостя: стандартный столик'),
            Text('• 5-6 гостей: большой столик'),
            Text('• 7+ гостей: может потребоваться несколько столиков'),
            SizedBox(height: 12),
            Text(
              'Для больших компаний рекомендуем звонить в заведение заранее.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
