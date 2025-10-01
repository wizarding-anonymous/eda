import '../entities/reservation.dart';
import '../entities/time_slot.dart';
import '../entities/table.dart';
import '../../core/utils/validators.dart';

/// Comprehensive validator for booking-related operations
class BookingValidator {
  /// Validate a reservation request
  static BookingValidationResult validateReservationRequest(
      ReservationRequest request) {
    final errors = <String>[];

    // Validate venue ID
    final venueError = Validators.validateVenueId(request.venueId);
    if (venueError != null) {
      errors.add(venueError);
    }

    // Validate date and time
    final dateTimeError =
        Validators.validateReservationDateTime(request.dateTime);
    if (dateTimeError != null) {
      errors.add(dateTimeError);
    }

    // Validate party size
    final partySizeError =
        Validators.validatePartySize(request.partySize.toString());
    if (partySizeError != null) {
      errors.add(partySizeError);
    }

    // Validate table type
    final tableTypeError = Validators.validateTableType(request.tableType);
    if (tableTypeError != null) {
      errors.add(tableTypeError);
    }

    // Validate notes
    final notesError = Validators.validateNotes(request.notes);
    if (notesError != null) {
      errors.add(notesError);
    }

    // Validate preorder items
    final preorderError =
        Validators.validatePreorderItems(request.preorderItems);
    if (preorderError != null) {
      errors.add(preorderError);
    }

    // Business logic validations
    if (request.dateTime.weekday == DateTime.sunday &&
        request.dateTime.hour < 12) {
      errors.add('Бронирование в воскресенье возможно только после 12:00');
    }

    if (request.partySize > 10 &&
        request.dateTime.difference(DateTime.now()).inHours < 24) {
      errors.add(
          'Для групп более 10 человек требуется бронирование минимум за 24 часа');
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate time slot availability for booking
  static BookingValidationResult validateTimeSlotForBooking(
    TimeSlot timeSlot,
    int partySize,
  ) {
    final errors = <String>[];

    if (!timeSlot.isAvailable) {
      errors.add('Выбранное время недоступно для бронирования');
    }

    if (timeSlot.isPast) {
      errors.add('Нельзя забронировать время в прошлом');
    }

    if (!timeSlot.canAccommodate(partySize)) {
      errors.add('Недостаточно мест для указанного количества гостей');
    }

    if (timeSlot.depositRequired != null && timeSlot.depositRequired! > 0) {
      // Additional validation for deposit requirements could be added here
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate table suitability for booking
  static BookingValidationResult validateTableForBooking(
    Table table,
    int partySize,
    String? preferredType,
  ) {
    final errors = <String>[];

    if (!table.isActive) {
      errors.add('Выбранный столик недоступен');
    }

    if (!table.canAccommodate(partySize)) {
      errors.add('Столик не подходит для указанного количества гостей');
    }

    if (preferredType != null && table.type.name != preferredType) {
      errors.add('Столик не соответствует предпочтительному типу');
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate preorder items
  static BookingValidationResult validatePreorderItems(
      List<PreorderItem> items) {
    final errors = <String>[];

    if (items.isEmpty) {
      return const BookingValidationResult(isValid: true, errors: []);
    }

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.quantity <= 0) {
        errors.add('Количество позиции "${item.name}" должно быть больше 0');
      }

      if (item.quantity > 20) {
        errors.add('Максимальное количество одной позиции: 20');
      }

      if (item.price <= 0) {
        errors.add('Цена позиции "${item.name}" должна быть больше 0');
      }

      if (item.name.trim().isEmpty) {
        errors.add('Название позиции не может быть пустым');
      }

      if (item.notes != null && item.notes!.length > 200) {
        errors.add(
            'Комментарий к позиции "${item.name}" не должен превышать 200 символов');
      }
    }

    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);
    if (totalItems > 100) {
      errors
          .add('Общее количество позиций в предзаказе не должно превышать 100');
    }

    final totalAmount =
        items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    if (totalAmount > 100000) {
      errors.add('Сумма предзаказа не должна превышать 100,000 рублей');
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate reservation cancellation
  static BookingValidationResult validateReservationCancellation(
    Reservation reservation,
    String reason,
  ) {
    final errors = <String>[];

    if (reservation.status == ReservationStatus.cancelled) {
      errors.add('Бронирование уже отменено');
    }

    if (reservation.status == ReservationStatus.completed) {
      errors.add('Нельзя отменить завершенное бронирование');
    }

    if (reservation.status == ReservationStatus.noShow) {
      errors.add('Нельзя отменить бронирование со статусом "не пришел"');
    }

    final now = DateTime.now();
    final timeDifference = reservation.startTime.difference(now);

    if (timeDifference.inHours < 2) {
      errors.add('Отмена бронирования возможна минимум за 2 часа до начала');
    }

    if (reason.trim().isEmpty) {
      errors.add('Причина отмены обязательна');
    }

    if (reason.length > 500) {
      errors.add('Причина отмены не должна превышать 500 символов');
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate time slot query parameters
  static BookingValidationResult validateTimeSlotQuery(TimeSlotQuery query) {
    final errors = <String>[];

    final venueError = Validators.validateVenueId(query.venueId);
    if (venueError != null) {
      errors.add(venueError);
    }

    final partySizeError =
        Validators.validatePartySize(query.partySize.toString());
    if (partySizeError != null) {
      errors.add(partySizeError);
    }

    if (query.date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors.add('Дата не может быть в прошлом');
    }

    if (query.date.isAfter(DateTime.now().add(const Duration(days: 90)))) {
      errors.add('Бронирование возможно максимум на 90 дней вперед');
    }

    if (query.preferredDuration != null) {
      if (query.preferredDuration!.inMinutes < 30) {
        errors.add('Минимальная продолжительность бронирования: 30 минут');
      }
      if (query.preferredDuration!.inHours > 6) {
        errors.add('Максимальная продолжительность бронирования: 6 часов');
      }
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate table query parameters
  static BookingValidationResult validateTableQuery(TableQuery query) {
    final errors = <String>[];

    final venueError = Validators.validateVenueId(query.venueId);
    if (venueError != null) {
      errors.add(venueError);
    }

    final partySizeError =
        Validators.validatePartySize(query.partySize.toString());
    if (partySizeError != null) {
      errors.add(partySizeError);
    }

    if (query.dateTime != null) {
      final dateTimeError =
          Validators.validateReservationDateTime(query.dateTime!);
      if (dateTimeError != null) {
        errors.add(dateTimeError);
      }
    }

    if (query.requiredAmenities != null &&
        query.requiredAmenities!.length > 10) {
      errors.add('Максимальное количество требуемых удобств: 10');
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Result of booking validation
class BookingValidationResult {
  final bool isValid;
  final List<String> errors;

  const BookingValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// Get the first error message, if any
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// Get all errors as a single formatted string
  String get allErrors => errors.join('\n');

  /// Check if there are any errors
  bool get hasErrors => errors.isNotEmpty;
}
