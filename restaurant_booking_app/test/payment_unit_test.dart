import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/domain/entities/payment.dart';
import 'package:restaurant_booking_app/domain/services/payment_security_service.dart';
import 'package:restaurant_booking_app/domain/services/preorder_payment_service.dart';

void main() {
  group('Payment Unit Tests', () {
    late PaymentSecurityService paymentSecurityService;

    setUp(() {
      paymentSecurityService = PaymentSecurityService();
    });

    group('Payment Security Tests', () {
      test('should validate payment security successfully for valid request',
          () {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1500.0,
          method: PaymentMethod.card,
        );

        // Act
        final result =
            paymentSecurityService.validatePaymentSecurity(paymentRequest);

        // Assert
        expect(result.isValid, true);
        expect(result.violations, isEmpty);
      });

      test('should detect security violations for large amounts', () {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 150000.0, // Above limit
          method: PaymentMethod.card,
        );

        // Act
        final result =
            paymentSecurityService.validatePaymentSecurity(paymentRequest);

        // Assert
        expect(result.isValid, false);
        expect(result.violations, isNotEmpty);
        expect(result.violations.first, contains('превышает лимит'));
      });

      test('should detect suspicious amounts', () {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 0.5, // Suspicious small amount
          method: PaymentMethod.card,
        );

        // Act
        final result =
            paymentSecurityService.validatePaymentSecurity(paymentRequest);

        // Assert
        expect(result.isValid, false);
        expect(result.violations, isNotEmpty);
      });

      test('should generate and validate payment tokens', () {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1500.0,
          method: PaymentMethod.card,
        );

        // Act
        final token =
            paymentSecurityService.generatePaymentToken(paymentRequest);
        final isValid =
            paymentSecurityService.validatePaymentToken(token, paymentRequest);

        // Assert
        expect(token, isNotEmpty);
        expect(token.length, 64); // SHA-256 hash length
        expect(isValid, true);
      });

      test('should generate fiscal receipt data correctly', () {
        // Arrange
        final order = Order(
          id: 'order_123',
          venueId: 'venue_123',
          source: OrderSource.preorder,
          status: OrderStatus.paid,
          items: const [
            OrderItem(
              id: 'item_1',
              menuItemId: 'menu_1',
              name: 'Паста Карбонара',
              quantity: 2,
              unitPrice: 750.0,
              totalPrice: 1500.0,
            ),
          ],
          totals: const OrderTotals(
            subtotal: 1500.0,
            discountTotal: 0.0,
            tipTotal: 0.0,
            serviceFee: 0.0,
            taxTotal: 300.0,
            total: 1500.0,
          ),
          createdAt: DateTime.now(),
        );

        const paymentResult = PaymentResult.success(
          transactionId: 'txn_123',
        );

        // Act
        final fiscalData = paymentSecurityService.generateFiscalReceiptData(
          order,
          paymentResult,
        );

        // Assert
        expect(fiscalData.orderId, 'order_123');
        expect(fiscalData.fiscalNumber, isNotEmpty);
        expect(fiscalData.fiscalNumber, startsWith('FN'));
        expect(fiscalData.items, hasLength(1));
        expect(fiscalData.items.first.name, 'Паста Карбонара');
        expect(fiscalData.items.first.quantity, 2);
        expect(fiscalData.items.first.price, 750.0);
        expect(fiscalData.items.first.total, 1500.0);
        expect(fiscalData.items.first.vatRate, 0.20);
        expect(fiscalData.paymentMethod, 'БЕЗНАЛИЧНЫМИ');
        expect(fiscalData.totals.subtotal, 1500.0);
        expect(fiscalData.totals.vatTotal, 300.0);
        expect(fiscalData.totals.total, 1500.0);
      });

      test('should encrypt and decrypt payment data', () {
        // Arrange
        const originalData = 'sensitive_payment_data_123';
        const key = 'encryption_key';

        // Act
        final encrypted =
            paymentSecurityService.encryptPaymentData(originalData, key);
        final decrypted =
            paymentSecurityService.decryptPaymentData(encrypted, key);

        // Assert
        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(originalData)));
        expect(decrypted, equals(originalData));
      });

      test('should validate PCI DSS compliance', () {
        // Act & Assert
        expect(
            paymentSecurityService.isPCIDSSCompliant(PaymentMethod.card), true);
        expect(
            paymentSecurityService.isPCIDSSCompliant(PaymentMethod.sbp), true);
      });

      test('should validate 3DS authentication', () {
        // Act & Assert
        expect(
            paymentSecurityService.validate3DSAuthentication('valid_3ds_data'),
            true);
        expect(paymentSecurityService.validate3DSAuthentication(''), false);
      });
    });

    group('Payment Method Tests', () {
      test('should support СБП payment method', () {
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1000.0,
          method: PaymentMethod.sbp,
        );

        expect(paymentRequest.method, PaymentMethod.sbp);
        expect(paymentRequest.method.name, 'sbp');
      });

      test('should support card payment method', () {
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1000.0,
          method: PaymentMethod.card,
        );

        expect(paymentRequest.method, PaymentMethod.card);
        expect(paymentRequest.method.name, 'card');
      });
    });

    group('Payment Entities Tests', () {
      test('should create PaymentRequest correctly', () {
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1500.0,
          method: PaymentMethod.card,
          tip: 150.0,
        );

        expect(paymentRequest.orderId, 'order_123');
        expect(paymentRequest.amount, 1500.0);
        expect(paymentRequest.method, PaymentMethod.card);
        expect(paymentRequest.tip, 150.0);
      });

      test('should create successful PaymentResult', () {
        const result = PaymentResult.success(
          transactionId: 'txn_123',
        );

        expect(result.isSuccess, true);
        expect(result.transactionId, 'txn_123');
        expect(result.errorMessage, null);
      });

      test('should create failed PaymentResult', () {
        const result = PaymentResult.failure(
          errorMessage: 'Payment failed',
        );

        expect(result.isSuccess, false);
        expect(result.transactionId, null);
        expect(result.errorMessage, 'Payment failed');
      });

      test('should create QRPaymentRequest correctly', () {
        const qrRequest = QRPaymentRequest(
          token: 'qr_token_123',
          amount: 2500.0,
          method: PaymentMethod.sbp,
          tip: 250.0,
        );

        expect(qrRequest.token, 'qr_token_123');
        expect(qrRequest.amount, 2500.0);
        expect(qrRequest.method, PaymentMethod.sbp);
        expect(qrRequest.tip, 250.0);
      });

      test('should create Receipt correctly', () {
        final receipt = Receipt(
          id: 'receipt_123',
          orderId: 'order_123',
          fiscalNumber: 'FN123456',
          timestamp: DateTime.now(),
          amount: 1500.0,
          qrCode: 'receipt_qr_code',
          pdfUrl: 'https://example.com/receipt.pdf',
        );

        expect(receipt.id, 'receipt_123');
        expect(receipt.orderId, 'order_123');
        expect(receipt.fiscalNumber, 'FN123456');
        expect(receipt.amount, 1500.0);
        expect(receipt.qrCode, 'receipt_qr_code');
        expect(receipt.pdfUrl, 'https://example.com/receipt.pdf');
      });
    });

    group('Payment Stage Tests', () {
      test('should have correct payment stages', () {
        expect(PaymentStage.validation.name, 'validation');
        expect(PaymentStage.payment.name, 'payment');
        expect(PaymentStage.reservation.name, 'reservation');
        expect(PaymentStage.completed.name, 'completed');
        expect(PaymentStage.unknown.name, 'unknown');
      });
    });
  });
}
