import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_form_provider.dart';
import '../../widgets/booking/date_selection_widget.dart';
import '../../widgets/booking/party_size_selector.dart';
import '../../widgets/booking/table_type_selector.dart';
import '../../widgets/booking/time_slots_grid.dart';
import '../../widgets/booking/notes_input_widget.dart';

class BookingFormPage extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;

  const BookingFormPage({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  ConsumerState<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends ConsumerState<BookingFormPage> {
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize the form with venue ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingFormProvider.notifier).updateVenueId(widget.venueId);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(bookingFormProvider);
    final formNotifier = ref.read(bookingFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бронирование'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.venueName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Selection
            _buildSectionCard(
              title: 'Дата посещения',
              child: DateSelectionWidget(
                selectedDate: formState.selectedDate,
                onDateSelected: (date) {
                  formNotifier.updateDate(date);
                  _scrollToNextSection();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Party Size Selection
            _buildSectionCard(
              title: 'Количество гостей',
              child: PartySizeSelector(
                selectedSize: formState.partySize,
                onSizeSelected: (size) {
                  formNotifier.updatePartySize(size);
                  _scrollToNextSection();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Table Type Selection (Optional)
            _buildSectionCard(
              title: 'Тип столика (необязательно)',
              child: TableTypeSelector(
                selectedType: formState.selectedTableType,
                onTypeSelected: formNotifier.updateTableType,
              ),
            ),

            const SizedBox(height: 16),

            // Time Slots
            if (formState.canLoadTimeSlots) ...[
              _buildSectionCard(
                title: 'Выберите время',
                child: TimeSlotsGrid(
                  timeSlots: formState.availableTimeSlots,
                  selectedTimeSlot: formState.selectedTimeSlot,
                  isLoading: formState.isLoadingTimeSlots,
                  error: formState.timeSlotsError,
                  onTimeSlotSelected: (timeSlot) {
                    formNotifier.selectTimeSlot(timeSlot);
                    _scrollToNextSection();
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes Input
            _buildSectionCard(
              title: 'Комментарии (необязательно)',
              child: NotesInputWidget(
                controller: _notesController,
                onChanged: formNotifier.updateNotes,
                hintText:
                    'Укажите особые пожелания: столик у окна, детский стульчик и т.д.',
              ),
            ),

            const SizedBox(height: 24),

            // Continue Button
            _buildContinueButton(formState, formNotifier),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    BookingFormState formState,
    BookingFormNotifier formNotifier,
  ) {
    final validation = formNotifier.validateForm();
    final isValid = validation.isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isValid && validation.errors.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Заполните обязательные поля:',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...validation.errors.map((error) => Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Text(
                        '• $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          onPressed:
              isValid ? () => _proceedToConfirmation(formNotifier) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Продолжить к подтверждению',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isValid && formState.selectedTimeSlot != null) ...[
          const SizedBox(height: 12),
          _buildBookingSummary(formState),
        ],
      ],
    );
  }

  Widget _buildBookingSummary(BookingFormState formState) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ru');
    final timeFormat = DateFormat('HH:mm');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Детали бронирования:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Дата:',
            dateFormat.format(formState.selectedDate!),
          ),
          _buildSummaryRow(
            'Время:',
            '${timeFormat.format(formState.selectedTimeSlot!.startTime)} - ${timeFormat.format(formState.selectedTimeSlot!.endTime)}',
          ),
          _buildSummaryRow(
            'Гостей:',
            '${formState.partySize} ${_getGuestWord(formState.partySize!)}',
          ),
          if (formState.selectedTableType != null)
            _buildSummaryRow(
              'Тип столика:',
              formState.selectedTableType!.displayName,
            ),
          if (formState.notes?.isNotEmpty == true)
            _buildSummaryRow(
              'Комментарии:',
              formState.notes!,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
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

  void _scrollToNextSection() {
    // Small delay to allow UI to update
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _proceedToConfirmation(BookingFormNotifier formNotifier) {
    final request = formNotifier.createReservationRequest();
    if (request != null) {
      // Show option to add preorder
      _showPreorderOption();
    }
  }

  void _showPreorderOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Предзаказ блюд'),
        content: const Text(
          'Хотите предзаказать блюда к вашему столику? '
          'Это поможет сократить время ожидания в заведении.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedWithoutPreorder();
            },
            child: const Text('Пропустить'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToPreorder();
            },
            child: const Text('Выбрать блюда'),
          ),
        ],
      ),
    );
  }

  void _proceedWithoutPreorder() {
    // Navigate directly to booking confirmation without payment
    context.pushReplacementNamed(
      'booking_confirmation',
      pathParameters: {
        'venueId': widget.venueId,
      },
      queryParameters: {
        'venueName': widget.venueName,
        'transactionId': 'booking_${DateTime.now().millisecondsSinceEpoch}',
        'hasPreorder': 'false',
      },
    );
  }

  void _navigateToPreorder() {
    // Navigate to preorder page
    context.pushNamed(
      'preorder',
      pathParameters: {'venueId': widget.venueId},
      queryParameters: {'venueName': widget.venueName},
    );
  }
}
