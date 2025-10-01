import 'package:injectable/injectable.dart';

import '../../domain/entities/reservation.dart';
import '../../domain/entities/payment.dart' as payment;
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/table.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/network/api_result.dart';
import '../datasources/remote/api_client.dart';

@Singleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl(this._apiClient);

  @override
  Future<ApiResult<Reservation>> createReservation(
      ReservationRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/reservations',
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        final reservation = Reservation.fromJson(data);
        return ApiResult.success(reservation);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<List<Reservation>>> getUserReservations({
    ReservationStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
    };

    final result = await _apiClient.get<Map<String, dynamic>>(
      '/reservations/me',
      queryParameters: queryParams,
    );

    return result.when(
      success: (data) {
        final reservations = (data['reservations'] as List)
            .map((json) => Reservation.fromJson(json))
            .toList();
        return ApiResult.success(reservations);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<Reservation>> getReservationDetails(
      String reservationId) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/reservations/$reservationId',
    );

    return result.when(
      success: (data) {
        final reservation = Reservation.fromJson(data);
        return ApiResult.success(reservation);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<void>> cancelReservation(
      String reservationId, String reason) async {
    final result = await _apiClient.patch<void>(
      '/reservations/$reservationId/cancel',
      data: {'reason': reason},
    );

    return result;
  }

  @override
  Future<ApiResult<Reservation>> updateReservation(
    String reservationId,
    ReservationRequest request,
  ) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      '/reservations/$reservationId',
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        final reservation = Reservation.fromJson(data);
        return ApiResult.success(reservation);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<payment.Order>> createPreorder(
      PreorderRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/orders/preorder',
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        final order = payment.Order.fromJson(data);
        return ApiResult.success(order);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<payment.Order>> getPreorderDetails(String orderId) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/orders/$orderId',
    );

    return result.when(
      success: (data) {
        final order = payment.Order.fromJson(data);
        return ApiResult.success(order);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<payment.Order>> updatePreorder(
      String orderId, PreorderRequest request) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      '/orders/$orderId',
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        final order = payment.Order.fromJson(data);
        return ApiResult.success(order);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<Reservation>> confirmReservation(
      String reservationId) async {
    final result = await _apiClient.patch<Map<String, dynamic>>(
      '/reservations/$reservationId/confirm',
    );

    return result.when(
      success: (data) {
        final reservation = Reservation.fromJson(data);
        return ApiResult.success(reservation);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<void>> checkIn(String reservationId) async {
    final result = await _apiClient.patch<void>(
      '/reservations/$reservationId/checkin',
    );

    return result;
  }

  // Time slot management implementations
  @override
  Future<ApiResult<List<TimeSlot>>> getAvailableTimeSlots(
      TimeSlotQuery query) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/venues/${query.venueId}/time-slots',
      queryParameters: query.toJson(),
    );

    return result.when(
      success: (data) {
        final timeSlots = (data['time_slots'] as List)
            .map((json) => TimeSlot.fromJson(json))
            .toList();
        return ApiResult.success(timeSlots);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<TimeSlot>> getTimeSlotDetails(String timeSlotId) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/time-slots/$timeSlotId',
    );

    return result.when(
      success: (data) {
        final timeSlot = TimeSlot.fromJson(data);
        return ApiResult.success(timeSlot);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<bool>> checkTimeSlotAvailability(
      String timeSlotId, int partySize) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/time-slots/$timeSlotId/availability',
      queryParameters: {'party_size': partySize},
    );

    return result.when(
      success: (data) {
        final isAvailable = data['is_available'] as bool;
        return ApiResult.success(isAvailable);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  // Table management implementations
  @override
  Future<ApiResult<List<TableAvailability>>> getAvailableTables(
      TableQuery query) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/venues/${query.venueId}/tables',
      queryParameters: query.toJson(),
    );

    return result.when(
      success: (data) {
        final tables = (data['tables'] as List)
            .map((json) => TableAvailability.fromJson(json))
            .toList();
        return ApiResult.success(tables);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<Table>> getTableDetails(String tableId) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/tables/$tableId',
    );

    return result.when(
      success: (data) {
        final table = Table.fromJson(data);
        return ApiResult.success(table);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<List<TableAvailability>>> getTableAvailability(
    String tableId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/tables/$tableId/availability',
      queryParameters: {
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      },
    );

    return result.when(
      success: (data) {
        final availability = (data['availability'] as List)
            .map((json) => TableAvailability.fromJson(json))
            .toList();
        return ApiResult.success(availability);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }
}
