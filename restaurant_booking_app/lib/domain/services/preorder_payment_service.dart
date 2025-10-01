import 'package:injectable/injectable.dart';
import '../entities/payment.dart';
import '../entities/reservation.dart';
import '../repositories/payment_repository.dart';
import '../repositories/booking_repository.dart';

/// Service for handling preorder payment processing
@injectable
class PreorderPaymentService {
  final PaymentRepository _paymentRepository;
  final BookingRepository _bookingRepository;

  PreorderPaymentService(
    this._paymentRepository,
    this._bookingRepository,
  );

  /// Process complete preorder payment flow
  Future<PreorderPaymentResult> processPreorderPayment({
    required PaymentRequest paymentRequest,
    required List<PreorderItem> preorderItems,
    required String venueId,
    String? reservationId,
    ReservationRequest? reservationRequest,
  }) async {
    try {
      // Step 1: Validate payment request
      final validationResult = _validatePaymentRequest(paymentRequest);
      if (!validationResult.isValid) {
        return PreorderPaymentResult.failure(
          error: validationResult.error!,
          stage: PaymentStage.validation,
        );
      }

      // Step 2: Process payment
      final paymentResult =
          await _paymentRepository.processPayment(paymentRequest);

      return paymentResult.when(
        success: (result) async {
          if (result.isSuccess) {
            // Step 3: Handle reservation creation/update
            try {
              String? finalReservationId = reservationId;

              if (reservationId != null) {
                // Update existing reservation with preorder
                await _updateReservationWithPreorder(
                    reservationId, preorderItems);
              } else if (reservationRequest != null) {
                // Create new reservation with preorder
                final reservation = await _createReservationWithPreorder(
                  reservationRequest.copyWith(preorderItems: preorderItems),
                );
                finalReservationId = reservation.id;
              }

              return PreorderPaymentResult.success(
                paymentResult: result,
                reservationId: finalReservationId,
                preorderItems: preorderItems,
                stage: PaymentStage.completed,
              );
            } catch (e) {
              // Payment succeeded but reservation failed
              // In a real app, we might need to refund the payment
              return PreorderPaymentResult.failure(
                error:
                    'Payment processed but reservation failed: ${e.toString()}',
                stage: PaymentStage.reservation,
                paymentResult: result,
              );
            }
          } else {
            return PreorderPaymentResult.failure(
              error: result.errorMessage ?? 'Payment failed',
              stage: PaymentStage.payment,
            );
          }
        },
        failure: (error) => PreorderPaymentResult.failure(
          error: error.message,
          stage: PaymentStage.payment,
        ),
      );
    } catch (e) {
      return PreorderPaymentResult.failure(
        error: 'Unexpected error: ${e.toString()}',
        stage: PaymentStage.unknown,
      );
    }
  }

  /// Validate payment request
  PaymentValidationResult _validatePaymentRequest(PaymentRequest request) {
    // Check amount
    if (request.amount <= 0) {
      return PaymentValidationResult.invalid('Сумма должна быть больше нуля');
    }

    if (request.amount > 999999) {
      return PaymentValidationResult.invalid(
          'Сумма превышает максимально допустимую');
    }

    // Check payment method
    if (!_isPaymentMethodSupported(request.method)) {
      return PaymentValidationResult.invalid('Способ оплаты не поддерживается');
    }

    return PaymentValidationResult.valid();
  }

  /// Check if payment method is supported
  bool _isPaymentMethodSupported(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sbp:
      case PaymentMethod.card:
        return true;
    }
  }

  /// Update existing reservation with preorder items
  Future<void> _updateReservationWithPreorder(
    String reservationId,
    List<PreorderItem> preorderItems,
  ) async {
    // This would call the booking repository to update the reservation
    // For now, we'll assume this is handled by the backend when processing payment
    // In a real implementation, you might need to call a specific endpoint

    // Example implementation:
    // await _bookingRepository.updateReservationPreorder(reservationId, preorderItems);
  }

  /// Create new reservation with preorder items
  Future<Reservation> _createReservationWithPreorder(
    ReservationRequest request,
  ) async {
    final result = await _bookingRepository.createReservation(request);

    return result.when(
      success: (reservation) => reservation,
      failure: (error) =>
          throw Exception('Failed to create reservation: ${error.message}'),
    );
  }

  /// Get payment processing fee
  double calculateProcessingFee(PaymentMethod method, double amount) {
    switch (method) {
      case PaymentMethod.sbp:
        return amount * 0.005; // 0.5% for СБП
      case PaymentMethod.card:
        return amount * 0.025; // 2.5% for cards
    }
  }

  /// Get estimated processing time
  Duration getEstimatedProcessingTime(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sbp:
        return const Duration(seconds: 30);
      case PaymentMethod.card:
        return const Duration(minutes: 2);
    }
  }
}

/// Result of preorder payment processing
class PreorderPaymentResult {
  final bool isSuccess;
  final PaymentResult? paymentResult;
  final String? reservationId;
  final List<PreorderItem>? preorderItems;
  final String? error;
  final PaymentStage stage;

  const PreorderPaymentResult._({
    required this.isSuccess,
    this.paymentResult,
    this.reservationId,
    this.preorderItems,
    this.error,
    required this.stage,
  });

  factory PreorderPaymentResult.success({
    required PaymentResult paymentResult,
    String? reservationId,
    required List<PreorderItem> preorderItems,
    required PaymentStage stage,
  }) {
    return PreorderPaymentResult._(
      isSuccess: true,
      paymentResult: paymentResult,
      reservationId: reservationId,
      preorderItems: preorderItems,
      stage: stage,
    );
  }

  factory PreorderPaymentResult.failure({
    required String error,
    required PaymentStage stage,
    PaymentResult? paymentResult,
  }) {
    return PreorderPaymentResult._(
      isSuccess: false,
      error: error,
      stage: stage,
      paymentResult: paymentResult,
    );
  }
}

/// Payment validation result
class PaymentValidationResult {
  final bool isValid;
  final String? error;

  const PaymentValidationResult._(this.isValid, this.error);

  factory PaymentValidationResult.valid() {
    return const PaymentValidationResult._(true, null);
  }

  factory PaymentValidationResult.invalid(String error) {
    return PaymentValidationResult._(false, error);
  }
}

/// Payment processing stages
enum PaymentStage {
  validation,
  payment,
  reservation,
  completed,
  unknown,
}

/// Extension to add preorder items to reservation request
extension ReservationRequestExtension on ReservationRequest {
  ReservationRequest copyWith({
    String? venueId,
    DateTime? dateTime,
    int? partySize,
    String? tableType,
    String? notes,
    List<PreorderItem>? preorderItems,
  }) {
    return ReservationRequest(
      venueId: venueId ?? this.venueId,
      dateTime: dateTime ?? this.dateTime,
      partySize: partySize ?? this.partySize,
      tableType: tableType ?? this.tableType,
      notes: notes ?? this.notes,
      preorderItems: preorderItems ?? this.preorderItems,
    );
  }
}
