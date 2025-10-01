import 'package:injectable/injectable.dart';
import '../../entities/payment.dart';
import '../../repositories/payment_repository.dart';
import '../../../core/network/api_result.dart';
import '../../../core/error/failures.dart';

@injectable
class ProcessQRPaymentUseCase {
  final PaymentRepository _paymentRepository;

  ProcessQRPaymentUseCase(this._paymentRepository);

  /// Process QR payment for table bill
  Future<ApiResult<PaymentResult>> call(QRPaymentRequest request) async {
    try {
      // Validate QR token first
      final sessionResult =
          await _paymentRepository.resolveQRToken(request.token);

      return sessionResult.when(
        success: (session) async {
          if (!session.isActive) {
            return const ApiResult.failure(
              ValidationFailure('QR код недействителен или истек'),
            );
          }

          if (session.expiresAt.isBefore(DateTime.now())) {
            return const ApiResult.failure(
              ValidationFailure('QR код истек'),
            );
          }

          // Process payment
          return await _paymentRepository.processQRPayment(request);
        },
        failure: (error) => ApiResult.failure(error),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure('Failed to process QR payment: ${e.toString()}'),
      );
    }
  }

  /// Get QR payment session details
  Future<ApiResult<QRPaymentSession>> getPaymentSession(String token) async {
    try {
      return await _paymentRepository.resolveQRToken(token);
    } catch (e) {
      return ApiResult.failure(
        ServerFailure('Failed to get payment session: ${e.toString()}'),
      );
    }
  }

  /// Validate QR payment request
  bool validatePaymentRequest(QRPaymentRequest request) {
    // Validate amount
    if (request.amount <= 0) {
      return false;
    }

    // Validate token format (basic check)
    if (request.token.isEmpty || request.token.length < 10) {
      return false;
    }

    // Validate tip amount if provided
    if (request.tip != null && request.tip! < 0) {
      return false;
    }

    return true;
  }

  /// Calculate total amount including tip
  double calculateTotalAmount(QRPaymentRequest request) {
    double total = request.amount;

    if (request.tip != null) {
      total += request.tip!;
    }

    return total;
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
}

// Remove these classes as they're already defined in failures.dart
