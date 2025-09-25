import '../entities/payment.dart';
import '../../core/network/api_result.dart';

abstract class PaymentRepository {
  /// Process payment for order
  Future<ApiResult<PaymentResult>> processPayment(PaymentRequest request);
  
  /// Resolve QR token to get payment session
  Future<ApiResult<QRPaymentSession>> resolveQRToken(String token);
  
  /// Get receipt by payment ID
  Future<ApiResult<Receipt>> getReceipt(String paymentId);
  
  /// Process QR payment
  Future<ApiResult<PaymentResult>> processQRPayment(QRPaymentRequest request);
  
  /// Get user's payment history
  Future<ApiResult<List<PaymentHistory>>> getPaymentHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  });
}

class PaymentTransaction {
  final String id;
  final String orderId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? description;
  final Receipt? receipt;

  const PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.description,
    this.receipt,
  });


}

enum PaymentStatus { pending, completed, failed, refunded }