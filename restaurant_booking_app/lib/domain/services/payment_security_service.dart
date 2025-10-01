import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../entities/payment.dart' as payment_entities;

/// Service for handling payment security and compliance
@injectable
class PaymentSecurityService {
  /// Validate payment request for security compliance
  PaymentSecurityResult validatePaymentSecurity(
      payment_entities.PaymentRequest request) {
    final validations = <String>[];

    // Check amount limits (54-ФЗ compliance)
    if (request.amount > 100000) {
      validations.add('Сумма превышает лимит для безналичных платежей');
    }

    // Validate payment method availability
    if (!_isPaymentMethodSecure(request.method)) {
      validations.add(
          'Выбранный способ оплаты не соответствует требованиям безопасности');
    }

    // Check for suspicious patterns
    if (_isSuspiciousAmount(request.amount)) {
      validations.add('Подозрительная сумма платежа');
    }

    return PaymentSecurityResult(
      isValid: validations.isEmpty,
      violations: validations,
    );
  }

  /// Generate secure payment token
  String generatePaymentToken(payment_entities.PaymentRequest request) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data =
        '${request.orderId}_${request.amount}_${request.method.name}_$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate payment token
  bool validatePaymentToken(
      String token, payment_entities.PaymentRequest request) {
    // In a real implementation, this would validate against stored tokens
    // For now, we'll just check if the token is not empty and has correct format
    return token.isNotEmpty && token.length == 64; // SHA-256 hash length
  }

  /// Check if payment method meets security requirements
  bool _isPaymentMethodSecure(payment_entities.PaymentMethod method) {
    switch (method) {
      case payment_entities.PaymentMethod.sbp:
        // СБП has built-in security through bank authentication
        return true;
      case payment_entities.PaymentMethod.card:
        // Card payments require 3DS authentication
        return true;
    }
  }

  /// Check for suspicious payment amounts
  bool _isSuspiciousAmount(double amount) {
    // Flag round numbers above certain threshold as potentially suspicious
    if (amount >= 50000 && amount % 1000 == 0) {
      return true;
    }

    // Flag very small amounts that might be test transactions
    if (amount < 1) {
      return true;
    }

    return false;
  }

  /// Generate fiscal receipt data (54-ФЗ compliance)
  FiscalReceiptData generateFiscalReceiptData(
    payment_entities.Order order,
    payment_entities.PaymentResult paymentResult,
  ) {
    return FiscalReceiptData(
      orderId: order.id,
      fiscalNumber: _generateFiscalNumber(),
      timestamp: DateTime.now(),
      items: order.items
          .map((item) => FiscalReceiptItem(
                name: item.name,
                quantity: item.quantity,
                price: item.unitPrice,
                total: item.totalPrice,
                vatRate: _getVATRate(item),
              ))
          .toList(),
      totals: FiscalReceiptTotals(
        subtotal: order.totals.subtotal,
        vatTotal: order.totals.taxTotal,
        total: order.totals.total,
      ),
      paymentMethod: _mapPaymentMethodToFiscal(paymentResult),
      customerInfo: null, // Optional for receipts
    );
  }

  /// Generate unique fiscal number
  String _generateFiscalNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'FN${timestamp.toString().substring(5)}';
  }

  /// Get VAT rate for item (НДС)
  double _getVATRate(payment_entities.OrderItem item) {
    // Most restaurant items are subject to 20% VAT in Russia
    return 0.20;
  }

  /// Map payment method to fiscal format
  String _mapPaymentMethodToFiscal(
      payment_entities.PaymentResult paymentResult) {
    // According to 54-ФЗ, payment methods should be specified
    return 'БЕЗНАЛИЧНЫМИ'; // Non-cash payment
  }

  /// Encrypt sensitive payment data
  String encryptPaymentData(String data, String key) {
    // In a real implementation, use proper encryption (AES-256)
    // For now, return base64 encoded data
    final bytes = utf8.encode(data);
    return base64.encode(bytes);
  }

  /// Decrypt sensitive payment data
  String decryptPaymentData(String encryptedData, String key) {
    // In a real implementation, use proper decryption
    // For now, return base64 decoded data
    final bytes = base64.decode(encryptedData);
    return utf8.decode(bytes);
  }

  /// Log payment transaction for audit (ФЗ-152 compliance)
  void logPaymentTransaction(
    payment_entities.PaymentRequest request,
    payment_entities.PaymentResult result,
    String userId,
  ) {
    final auditLog = PaymentAuditLog(
      timestamp: DateTime.now(),
      userId: userId,
      orderId: request.orderId,
      amount: request.amount,
      method: request.method,
      success: result.isSuccess,
      transactionId: result.transactionId,
      errorMessage: result.errorMessage,
    );

    // In a real implementation, this would be sent to a secure audit system
    _storeAuditLog(auditLog);
  }

  /// Store audit log securely
  void _storeAuditLog(PaymentAuditLog log) {
    // Implementation would store in secure audit database
    // with proper encryption and access controls
    // TODO: Replace with proper logging framework (e.g., logger package)
    // logger.info('Audit log stored: ${log.toJson()}');
  }

  /// Check PCI DSS compliance for card payments
  bool isPCIDSSCompliant(payment_entities.PaymentMethod method) {
    if (method == payment_entities.PaymentMethod.card) {
      // In a real implementation, verify PCI DSS compliance
      // Check if payment processor is certified
      return true;
    }
    return true; // Other methods don't require PCI DSS
  }

  /// Validate 3DS authentication for card payments
  bool validate3DSAuthentication(String authenticationData) {
    // In a real implementation, validate 3DS response
    return authenticationData.isNotEmpty;
  }
}

/// Result of payment security validation
class PaymentSecurityResult {
  final bool isValid;
  final List<String> violations;

  const PaymentSecurityResult({
    required this.isValid,
    required this.violations,
  });
}

/// Fiscal receipt data for 54-ФЗ compliance
class FiscalReceiptData {
  final String orderId;
  final String fiscalNumber;
  final DateTime timestamp;
  final List<FiscalReceiptItem> items;
  final FiscalReceiptTotals totals;
  final String paymentMethod;
  final String? customerInfo;

  const FiscalReceiptData({
    required this.orderId,
    required this.fiscalNumber,
    required this.timestamp,
    required this.items,
    required this.totals,
    required this.paymentMethod,
    this.customerInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'fiscal_number': fiscalNumber,
      'timestamp': timestamp.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'totals': totals.toJson(),
      'payment_method': paymentMethod,
      'customer_info': customerInfo,
    };
  }
}

/// Fiscal receipt item
class FiscalReceiptItem {
  final String name;
  final int quantity;
  final double price;
  final double total;
  final double vatRate;

  const FiscalReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    required this.vatRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
      'vat_rate': vatRate,
    };
  }
}

/// Fiscal receipt totals
class FiscalReceiptTotals {
  final double subtotal;
  final double vatTotal;
  final double total;

  const FiscalReceiptTotals({
    required this.subtotal,
    required this.vatTotal,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'vat_total': vatTotal,
      'total': total,
    };
  }
}

/// Payment audit log for compliance
class PaymentAuditLog {
  final DateTime timestamp;
  final String userId;
  final String orderId;
  final double amount;
  final payment_entities.PaymentMethod method;
  final bool success;
  final String? transactionId;
  final String? errorMessage;

  const PaymentAuditLog({
    required this.timestamp,
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.success,
    this.transactionId,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
      'order_id': orderId,
      'amount': amount,
      'method': method.name,
      'success': success,
      'transaction_id': transactionId,
      'error_message': errorMessage,
    };
  }
}
