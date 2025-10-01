import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/di/injection.dart';
import '../../core/network/api_result.dart';

/// Provider for payment state management
final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(
    getIt<PaymentRepository>(),
    getIt<BookingRepository>(),
  );
});

/// Provider for payment history
final paymentHistoryProvider =
    FutureProvider.family<List<PaymentHistory>, PaymentHistoryParams>(
        (ref, params) async {
  final repository = getIt<PaymentRepository>();
  final result = await repository.getPaymentHistory(
    page: params.page,
    limit: params.limit,
    startDate: params.startDate,
    endDate: params.endDate,
  );

  return result.when(
    success: (history) => history,
    failure: (error) => throw Exception(error.message),
  );
});

class PaymentHistoryParams {
  final int page;
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentHistoryParams({
    this.page = 1,
    this.limit = 20,
    this.startDate,
    this.endDate,
  });
}

class PaymentState {
  final bool isProcessing;
  final PaymentResult? lastResult;
  final String? error;
  final List<PaymentHistory> history;

  const PaymentState({
    this.isProcessing = false,
    this.lastResult,
    this.error,
    this.history = const [],
  });

  PaymentState copyWith({
    bool? isProcessing,
    PaymentResult? lastResult,
    String? error,
    List<PaymentHistory>? history,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastResult: lastResult ?? this.lastResult,
      error: error ?? this.error,
      history: history ?? this.history,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _paymentRepository;
  final BookingRepository _bookingRepository;

  PaymentNotifier(this._paymentRepository, this._bookingRepository)
      : super(const PaymentState());

  /// Process preorder payment and create reservation
  Future<PaymentResult> processPreorderPayment(
    PaymentRequest paymentRequest,
    List<PreorderItem> preorderItems,
    String venueId,
    String? reservationId,
  ) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // First, process the payment
      final paymentResult =
          await _paymentRepository.processPayment(paymentRequest);

      return paymentResult.when(
        success: (result) async {
          if (result.isSuccess) {
            // If payment successful and we have a reservation ID, update it with preorder
            if (reservationId != null) {
              await _updateReservationWithPreorder(
                  reservationId, preorderItems);
            }

            state = state.copyWith(
              isProcessing: false,
              lastResult: result,
            );
            return result;
          } else {
            state = state.copyWith(
              isProcessing: false,
              error: result.errorMessage,
              lastResult: result,
            );
            return result;
          }
        },
        failure: (error) {
          final failureResult =
              PaymentResult.failure(errorMessage: error.message);
          state = state.copyWith(
            isProcessing: false,
            error: error.message,
            lastResult: failureResult,
          );
          return failureResult;
        },
      );
    } catch (e) {
      final failureResult = PaymentResult.failure(errorMessage: e.toString());
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
        lastResult: failureResult,
      );
      return failureResult;
    }
  }

  /// Process QR payment
  Future<PaymentResult> processQRPayment(QRPaymentRequest request) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final result = await _paymentRepository.processQRPayment(request);

      return result.when(
        success: (paymentResult) {
          state = state.copyWith(
            isProcessing: false,
            lastResult: paymentResult,
          );
          return paymentResult;
        },
        failure: (error) {
          final failureResult =
              PaymentResult.failure(errorMessage: error.message);
          state = state.copyWith(
            isProcessing: false,
            error: error.message,
            lastResult: failureResult,
          );
          return failureResult;
        },
      );
    } catch (e) {
      final failureResult = PaymentResult.failure(errorMessage: e.toString());
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
        lastResult: failureResult,
      );
      return failureResult;
    }
  }

  /// Get QR payment session
  Future<QRPaymentSession?> getQRPaymentSession(String token) async {
    try {
      final result = await _paymentRepository.resolveQRToken(token);

      return result.when(
        success: (session) => session,
        failure: (error) {
          state = state.copyWith(error: error.message);
          return null;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get receipt for payment
  Future<Receipt?> getReceipt(String paymentId) async {
    try {
      final result = await _paymentRepository.getReceipt(paymentId);

      return result.when(
        success: (receipt) => receipt,
        failure: (error) {
          state = state.copyWith(error: error.message);
          return null;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Load payment history
  Future<void> loadPaymentHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _paymentRepository.getPaymentHistory(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      result.when(
        success: (history) {
          state = state.copyWith(history: history);
        },
        failure: (error) {
          state = state.copyWith(error: error.message);
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear last payment result
  void clearLastResult() {
    state = state.copyWith(lastResult: null);
  }

  /// Helper method to update reservation with preorder items
  Future<void> _updateReservationWithPreorder(
    String reservationId,
    List<PreorderItem> preorderItems,
  ) async {
    try {
      // This would call the booking repository to update the reservation
      // with preorder items. Implementation depends on the booking repository interface.
      // For now, we'll assume this is handled by the backend when processing payment.
    } catch (e) {
      // Log error but don't fail the payment process
      print('Failed to update reservation with preorder: $e');
    }
  }
}

/// Provider for validating payment methods
final paymentMethodValidatorProvider = Provider<PaymentMethodValidator>((ref) {
  return PaymentMethodValidator();
});

class PaymentMethodValidator {
  /// Validate if payment method is available
  bool isPaymentMethodAvailable(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sbp:
        // СБП is available in Russia
        return true;
      case PaymentMethod.card:
        // Card payments are always available
        return true;
    }
  }

  /// Get payment method display name
  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sbp:
        return 'Система быстрых платежей';
      case PaymentMethod.card:
        return 'Банковская карта';
    }
  }

  /// Get payment method description
  String getPaymentMethodDescription(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sbp:
        return 'Оплата через банковское приложение';
      case PaymentMethod.card:
        return 'Мир, Visa, Mastercard';
    }
  }

  /// Validate payment amount
  bool isValidPaymentAmount(double amount) {
    return amount > 0 && amount <= 999999; // Max 999,999 rubles
  }

  /// Get minimum payment amount
  double getMinimumPaymentAmount() {
    return 1.0; // 1 ruble minimum
  }

  /// Get maximum payment amount
  double getMaximumPaymentAmount() {
    return 999999.0; // 999,999 rubles maximum
  }
}
