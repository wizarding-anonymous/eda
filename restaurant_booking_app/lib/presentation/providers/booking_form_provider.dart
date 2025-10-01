import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/table.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/validators/booking_validator.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/local/local_storage.dart';
import 'package:dio/dio.dart';

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  final BookingRepository _bookingRepository;

  BookingFormNotifier(this._bookingRepository)
      : super(const BookingFormState());

  void updateVenueId(String venueId) {
    state = state.copyWith(venueId: venueId);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      selectedTimeSlot: null, // Reset time slot when date changes
      availableTimeSlots: [],
    );
    _loadAvailableTimeSlots();
  }

  void updatePartySize(int partySize) {
    state = state.copyWith(
      partySize: partySize,
      selectedTimeSlot: null, // Reset time slot when party size changes
      availableTimeSlots: [],
    );
    _loadAvailableTimeSlots();
  }

  void updateTableType(TableType? tableType) {
    state = state.copyWith(selectedTableType: tableType);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void selectTimeSlot(TimeSlot timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (state.venueId == null ||
        state.selectedDate == null ||
        state.partySize == null) {
      return;
    }

    state = state.copyWith(isLoadingTimeSlots: true, timeSlotsError: null);

    try {
      final query = TimeSlotQuery(
        venueId: state.venueId!,
        date: state.selectedDate!,
        partySize: state.partySize!,
        tableType: state.selectedTableType?.name,
      );

      final result = await _bookingRepository.getAvailableTimeSlots(query);

      result.when(
        success: (timeSlots) {
          state = state.copyWith(
            availableTimeSlots: timeSlots,
            isLoadingTimeSlots: false,
          );
        },
        failure: (error) {
          state = state.copyWith(
            isLoadingTimeSlots: false,
            timeSlotsError: error.message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingTimeSlots: false,
        timeSlotsError: 'Ошибка загрузки доступных слотов: $e',
      );
    }
  }

  BookingValidationResult validateForm() {
    if (state.venueId == null) {
      return const BookingValidationResult(
        isValid: false,
        errors: ['Заведение не выбрано'],
      );
    }

    if (state.selectedDate == null) {
      return const BookingValidationResult(
        isValid: false,
        errors: ['Дата не выбрана'],
      );
    }

    if (state.partySize == null) {
      return const BookingValidationResult(
        isValid: false,
        errors: ['Количество гостей не указано'],
      );
    }

    if (state.selectedTimeSlot == null) {
      return const BookingValidationResult(
        isValid: false,
        errors: ['Время не выбрано'],
      );
    }

    final request = ReservationRequest(
      venueId: state.venueId!,
      dateTime: state.selectedTimeSlot!.startTime,
      partySize: state.partySize!,
      tableType: state.selectedTableType?.name,
      notes: state.notes?.isNotEmpty == true ? state.notes : null,
    );

    return BookingValidator.validateReservationRequest(request);
  }

  ReservationRequest? createReservationRequest() {
    final validation = validateForm();
    if (!validation.isValid) {
      return null;
    }

    return ReservationRequest(
      venueId: state.venueId!,
      dateTime: state.selectedTimeSlot!.startTime,
      partySize: state.partySize!,
      tableType: state.selectedTableType?.name,
      notes: state.notes?.isNotEmpty == true ? state.notes : null,
    );
  }

  void reset() {
    state = const BookingFormState();
  }
}

class BookingFormState {
  final String? venueId;
  final DateTime? selectedDate;
  final int? partySize;
  final TableType? selectedTableType;
  final String? notes;
  final TimeSlot? selectedTimeSlot;
  final List<TimeSlot> availableTimeSlots;
  final bool isLoadingTimeSlots;
  final String? timeSlotsError;

  const BookingFormState({
    this.venueId,
    this.selectedDate,
    this.partySize,
    this.selectedTableType,
    this.notes,
    this.selectedTimeSlot,
    this.availableTimeSlots = const [],
    this.isLoadingTimeSlots = false,
    this.timeSlotsError,
  });

  BookingFormState copyWith({
    String? venueId,
    DateTime? selectedDate,
    int? partySize,
    TableType? selectedTableType,
    String? notes,
    TimeSlot? selectedTimeSlot,
    List<TimeSlot>? availableTimeSlots,
    bool? isLoadingTimeSlots,
    String? timeSlotsError,
  }) {
    return BookingFormState(
      venueId: venueId ?? this.venueId,
      selectedDate: selectedDate ?? this.selectedDate,
      partySize: partySize ?? this.partySize,
      selectedTableType: selectedTableType ?? this.selectedTableType,
      notes: notes ?? this.notes,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      isLoadingTimeSlots: isLoadingTimeSlots ?? this.isLoadingTimeSlots,
      timeSlotsError: timeSlotsError ?? this.timeSlotsError,
    );
  }

  bool get isFormValid {
    return venueId != null &&
        selectedDate != null &&
        partySize != null &&
        selectedTimeSlot != null;
  }

  bool get canLoadTimeSlots {
    return venueId != null && selectedDate != null && partySize != null;
  }
}

// Provider for the booking form
final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return BookingFormNotifier(bookingRepository);
});

// Provider for the booking repository
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  // Create dependencies - in a real app, these would be injected properly
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.restaurant-booking.com/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  final localStorage = LocalStorage();
  final apiClient = ApiClient(dio, localStorage);

  return BookingRepositoryImpl(apiClient);
});
