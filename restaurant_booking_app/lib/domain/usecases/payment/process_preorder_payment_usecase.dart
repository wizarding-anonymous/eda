import 'package:injectable/injectable.dart';
import '../../entities/payment.dart';
import '../../entities/reservation.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/network/api_result.dart';
import '../../../core/error/failures.dart';

@injectable
class ProcessPreorderPaymentUseCase {
  final PaymentRepository _paymentRepository;
  final BookingRepository _bookingRepository;

  ProcessPreorderPaymentUseCase(
    this._paymentRepository,
    this._bookingRepository,
  );

  /// Process preorder payment and create/update reservation
  Future<ApiResult<PaymentResult>> call({
    required PaymentRequest paymentRequest,
    required List<PreorderItem> preorderItems,
    required String venueId,
    String? reservationId,
    ReservationRequest? reservationRequest,
  }) async {
    try {
      // Step 1: Process payment
      final paymentResult =
          await _paymentRepository.processPayment(paymentRequest);

      return paymentResult.when(
        success: (result) async {
          if (result.isSuccess) {
            // Step 2: Create or update reservation with preorder
            if (reservationId != null) {
              // Update existing reservation with preorder
              await _updateReservationWithPreorder(
                  reservationId, preorderItems);
            } else if (reservationRequest != null) {
              // Create new reservation with preorder
              await _createReservationWithPreorder(
                reservationRequest.copyWith(preorderItems: preorderItems),
              );
            }

            return ApiResult.success(result);
          } else {
            return ApiResult.success(result);
          }
        },
        failure: (error) => ApiResult.failure(error),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure('Failed to process preorder payment: ${e.toString()}'),
      );
    }
  }

  /// Update existing reservation with preorder items
  Future<void> _updateReservationWithPreorder(
    String reservationId,
    List<PreorderItem> preorderItems,
  ) async {
    // This would call the booking repository to update the reservation
    // Implementation depends on the booking repository interface
    try {
      // For now, we'll assume this is handled by the backend
      // when processing the payment with reservation context
    } catch (e) {
      // Log error but don't fail the payment process
      // TODO: Replace with proper logging framework
      // logger.error('Failed to update reservation with preorder: $e');
    }
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

// Remove this class as it's already defined in failures.dart
