import 'package:injectable/injectable.dart';

import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../core/network/api_result.dart';
import '../datasources/remote/api_client.dart';

@Singleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepositoryImpl(this._apiClient);

  @override
  Future<ApiResult<PaymentResult>> processPayment(
      PaymentRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/payments/process',
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        final paymentResult = PaymentResult.fromJson(data);
        return ApiResult.success(paymentResult);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<QRPaymentSession>> resolveQRToken(String token) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/payments/qr/$token',
    );

    return result.when(
      success: (data) {
        final session = QRPaymentSession.fromJson(data);
        return ApiResult.success(session);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<Receipt>> getReceipt(String paymentId) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/payments/$paymentId/receipt',
    );

    return result.when(
      success: (data) {
        final receipt = Receipt.fromJson(data);
        return ApiResult.success(receipt);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<PaymentResult>> processQRPayment(
      QRPaymentRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/payments/qr/pay',
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        final paymentResult = PaymentResult.fromJson(data);
        return ApiResult.success(paymentResult);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<List<PaymentHistory>>> getPaymentHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final result = await _apiClient.get<Map<String, dynamic>>(
      '/payments/history',
      queryParameters: queryParams,
    );

    return result.when(
      success: (data) {
        final payments = (data['payments'] as List)
            .map((json) => PaymentHistory.fromJson(json))
            .toList();
        return ApiResult.success(payments);
      },
      failure: (failure) => ApiResult.failure(failure),
    );
  }
}
