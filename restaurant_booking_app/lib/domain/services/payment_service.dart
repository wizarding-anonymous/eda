import 'package:injectable/injectable.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';
import '../../core/network/api_result.dart';

/// Abstract payment service interface
abstract class PaymentService {
  /// Initialize payment providers
  Future<void> initialize();

  /// Check if payment method is available
  bool isPaymentMethodAvailable(PaymentMethod method);

  /// Process payment with specific provider
  Future<PaymentResult> processPayment(PaymentRequest request);

  /// Process QR payment
  Future<PaymentResult> processQRPayment(QRPaymentRequest request);

  /// Get supported payment methods
  List<PaymentMethod> getSupportedPaymentMethods();

  /// Validate payment amount
  bool validatePaymentAmount(double amount);

  /// Get payment method configuration
  PaymentMethodConfig getPaymentMethodConfig(PaymentMethod method);
}

/// Payment method configuration
class PaymentMethodConfig {
  final PaymentMethod method;
  final String displayName;
  final String description;
  final double minAmount;
  final double maxAmount;
  final bool isEnabled;
  final Map<String, dynamic> providerConfig;

  const PaymentMethodConfig({
    required this.method,
    required this.displayName,
    required this.description,
    required this.minAmount,
    required this.maxAmount,
    required this.isEnabled,
    this.providerConfig = const {},
  });
}

/// Implementation of payment service
@Singleton(as: PaymentService)
class PaymentServiceImpl implements PaymentService {
  final PaymentRepository _paymentRepository;

  // Payment provider configurations
  static const Map<PaymentMethod, PaymentMethodConfig> _paymentConfigs = {
    PaymentMethod.sbp: PaymentMethodConfig(
      method: PaymentMethod.sbp,
      displayName: 'Система быстрых платежей',
      description: 'Оплата через банковское приложение',
      minAmount: 1.0,
      maxAmount: 999999.0,
      isEnabled: true,
      providerConfig: {
        'provider': 'sbp',
        'timeout': 300, // 5 minutes
        'supportedBanks': ['sber', 'vtb', 'alpha', 'tinkoff'],
      },
    ),
    PaymentMethod.card: PaymentMethodConfig(
      method: PaymentMethod.card,
      displayName: 'Банковская карта',
      description: 'Мир, Visa, Mastercard',
      minAmount: 1.0,
      maxAmount: 999999.0,
      isEnabled: true,
      providerConfig: {
        'provider': 'yookassa', // or 'cloudpayments'
        'supportedCards': ['mir', 'visa', 'mastercard'],
        'require3DS': true,
      },
    ),
  };

  PaymentServiceImpl(this._paymentRepository);

  @override
  Future<void> initialize() async {
    // Initialize payment providers
    // This would typically involve setting up SDK configurations
    // for YooKassa, CloudPayments, etc.

    try {
      // Initialize СБП provider
      await _initializeSBPProvider();

      // Initialize card payment provider
      await _initializeCardProvider();

      print('Payment service initialized successfully');
    } catch (e) {
      print('Failed to initialize payment service: $e');
      rethrow;
    }
  }

  @override
  bool isPaymentMethodAvailable(PaymentMethod method) {
    final config = _paymentConfigs[method];
    return config?.isEnabled ?? false;
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // Validate payment request
    if (!validatePaymentAmount(request.amount)) {
      return const PaymentResult.failure(
        errorMessage: 'Некорректная сумма платежа',
      );
    }

    if (!isPaymentMethodAvailable(request.method)) {
      return const PaymentResult.failure(
        errorMessage: 'Способ оплаты недоступен',
      );
    }

    // Process payment through repository
    final result = await _paymentRepository.processPayment(request);

    return result.when(
      success: (paymentResult) => paymentResult,
      failure: (error) => PaymentResult.failure(
        errorMessage: error.message,
      ),
    );
  }

  @override
  Future<PaymentResult> processQRPayment(QRPaymentRequest request) async {
    // Validate QR payment request
    if (!validatePaymentAmount(request.amount)) {
      return const PaymentResult.failure(
        errorMessage: 'Некорректная сумма платежа',
      );
    }

    if (!isPaymentMethodAvailable(request.method)) {
      return const PaymentResult.failure(
        errorMessage: 'Способ оплаты недоступен',
      );
    }

    // Process QR payment through repository
    final result = await _paymentRepository.processQRPayment(request);

    return result.when(
      success: (paymentResult) => paymentResult,
      failure: (error) => PaymentResult.failure(
        errorMessage: error.message,
      ),
    );
  }

  @override
  List<PaymentMethod> getSupportedPaymentMethods() {
    return _paymentConfigs.entries
        .where((entry) => entry.value.isEnabled)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  bool validatePaymentAmount(double amount) {
    return amount > 0 && amount <= 999999.0;
  }

  @override
  PaymentMethodConfig getPaymentMethodConfig(PaymentMethod method) {
    return _paymentConfigs[method] ??
        const PaymentMethodConfig(
          method: PaymentMethod.card,
          displayName: 'Unknown',
          description: 'Unknown payment method',
          minAmount: 0,
          maxAmount: 0,
          isEnabled: false,
        );
  }

  /// Initialize СБП (Fast Payment System) provider
  Future<void> _initializeSBPProvider() async {
    // This would initialize the СБП SDK or API client
    // For now, we'll just simulate initialization
    await Future.delayed(const Duration(milliseconds: 100));
    print('СБП provider initialized');
  }

  /// Initialize card payment provider (YooKassa/CloudPayments)
  Future<void> _initializeCardProvider() async {
    // This would initialize the card payment SDK
    // For now, we'll just simulate initialization
    await Future.delayed(const Duration(milliseconds: 100));
    print('Card payment provider initialized');
  }

  /// Get payment provider specific configuration
  Map<String, dynamic> getProviderConfig(PaymentMethod method) {
    return _paymentConfigs[method]?.providerConfig ?? {};
  }

  /// Calculate processing fee for payment method
  double calculateProcessingFee(PaymentMethod method, double amount) {
    switch (method) {
      case PaymentMethod.sbp:
        // СБП typically has lower fees
        return amount * 0.005; // 0.5%
      case PaymentMethod.card:
        // Card payments have higher fees
        return amount * 0.025; // 2.5%
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

  /// Check if payment method supports refunds
  bool supportsRefunds(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sbp:
        return true;
      case PaymentMethod.card:
        return true;
    }
  }

  /// Get payment method icon name
  String getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sbp:
        return 'account_balance';
      case PaymentMethod.card:
        return 'credit_card';
    }
  }
}
