import 'package:flutter/material.dart';

class NotesInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? hintText;
  final int maxLength;
  final int maxLines;

  const NotesInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.maxLength = 500,
    this.maxLines = 4,
  });

  @override
  State<NotesInputWidget> createState() => _NotesInputWidgetState();
}

class _NotesInputWidgetState extends State<NotesInputWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text input field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText:
                widget.hintText ?? 'Добавьте комментарий к бронированию...',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.5),
              ),
            ),
            prefixIcon: Icon(
              Icons.edit_note,
              color: _isFocused
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.6),
            ),
            counterStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.6),
              fontSize: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: widget.onChanged,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        // Quick suggestion chips
        _buildQuickSuggestions(context),

        const SizedBox(height: 8),

        // Help text
        _buildHelpText(context),
      ],
    );
  }

  Widget _buildQuickSuggestions(BuildContext context) {
    final suggestions = [
      'Столик у окна',
      'Детский стульчик',
      'Тихое место',
      'Романтическая обстановка',
      'Аллергия на орехи',
      'Вегетарианское меню',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрые варианты:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: suggestions
              .map((suggestion) => _buildSuggestionChip(
                    context,
                    suggestion,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String suggestion) {
    return ActionChip(
      label: Text(
        suggestion,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () => _addSuggestion(suggestion),
      backgroundColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5),
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildHelpText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Укажите особые пожелания: предпочтения по расположению столика, диетические ограничения, необходимость детского стульчика и т.д.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSuggestion(String suggestion) {
    final currentText = widget.controller.text;
    final newText =
        currentText.isEmpty ? suggestion : '$currentText, $suggestion';

    if (newText.length <= widget.maxLength) {
      widget.controller.text = newText;
      widget.onChanged(newText);

      // Move cursor to end
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }
  }
}
