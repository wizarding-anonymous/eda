import '../entities/reservation.dart';
import '../entities/payment.dart';
import '../../core/network/api_result.dart';

abstract class BookingRepository {
  /// Create a new reservation
  Future<ApiResult<Reservation>> createReservation(ReservationRequest request);
  
  /// Get user's reservations
  Future<ApiResult<List<Reservation>>> getUserReservations({
    ReservationStatus? status,
    int page = 1,
    int limit = 20,
  });
  
  /// Get reservation details
  Future<ApiResult<Reservation>> getReservationDetails(String reservationId);
  
  /// Cancel reservation
  Future<ApiResult<void>> cancelReservation(String reservationId, String reason);
  
  /// Update reservation
  Future<ApiResult<Reservation>> updateReservation(
    String reservationId,
    ReservationRequest request,
  );
  
  /// Create preorder for reservation
  Future<ApiResult<Order>> createPreorder(PreorderRequest request);
  
  /// Get preorder details
  Future<ApiResult<Order>> getPreorderDetails(String orderId);
  
  /// Update preorder
  Future<ApiResult<Order>> updatePreorder(String orderId, PreorderRequest request);
  
  /// Confirm reservation (by venue)
  Future<ApiResult<Reservation>> confirmReservation(String reservationId);
  
  /// Check-in to reservation
  Future<ApiResult<void>> checkIn(String reservationId);
}

class PreorderRequest {
  final String reservationId;
  final List<PreorderItem> items;
  final String? notes;

  const PreorderRequest({
    required this.reservationId,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'reservation_id': reservationId,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }
}