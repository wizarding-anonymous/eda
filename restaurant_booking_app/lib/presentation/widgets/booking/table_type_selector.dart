import 'package:flutter/material.dart';
import '../../../domain/entities/table.dart';

class TableTypeSelector extends StatelessWidget {
  final TableType? selectedType;
  final Function(TableType?) onTypeSelected;
  final List<TableType>? availableTypes;

  const TableTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.availableTypes,
  });

  @override
  Widget build(BuildContext context) {
    final types = availableTypes ?? TableType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clear selection option
        _buildClearSelectionChip(context),

        const SizedBox(height: 12),

        // Table type chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              types.map((type) => _buildTableTypeChip(context, type)).toList(),
        ),

        const SizedBox(height: 12),

        // Information about table types
        _buildTableTypeInfo(context),

        if (selectedType != null) ...[
          const SizedBox(height: 12),
          _buildSelectedTypeDisplay(context),
        ],
      ],
    );
  }

  Widget _buildClearSelectionChip(BuildContext context) {
    final isSelected = selectedType == null;

    return FilterChip(
      label: const Text('Любой столик'),
      selected: isSelected,
      onSelected: (_) => onTypeSelected(null),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      avatar: isSelected ? null : const Icon(Icons.clear, size: 18),
    );
  }

  Widget _buildTableTypeChip(BuildContext context, TableType type) {
    final isSelected = selectedType == type;

    return FilterChip(
      label: Text(type.displayName),
      selected: isSelected,
      onSelected: (_) => onTypeSelected(isSelected ? null : type),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      avatar: Icon(_getTableTypeIcon(type), size: 18),
    );
  }

  Widget _buildTableTypeInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Типы столиков:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._getTableTypeDescriptions().map((desc) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSelectedTypeDisplay(BuildContext context) {
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
          Icon(
            _getTableTypeIcon(selectedType!),
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            'Предпочтение: ${selectedType!.displayName}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTableTypeIcon(TableType type) {
    switch (type) {
      case TableType.standard:
        return Icons.table_restaurant;
      case TableType.vip:
        return Icons.star;
      case TableType.booth:
        return Icons.weekend;
      case TableType.bar:
        return Icons.local_bar;
      case TableType.outdoor:
        return Icons.deck;
      case TableType.private:
        return Icons.meeting_room;
    }
  }

  List<String> _getTableTypeDescriptions() {
    return [
      '• Обычный - стандартный столик в основном зале',
      '• VIP - премиум столик с особым сервисом',
      '• Кабинка - уютное место с повышенной приватностью',
      '• Барная стойка - высокие стулья у бара',
      '• Летняя веранда - столик на открытом воздухе',
      '• Приватная зона - отдельное помещение для компании',
    ];
  }
}
