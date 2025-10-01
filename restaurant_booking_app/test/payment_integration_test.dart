import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:restaurant_booking_app/domain/entities/payment.dart';
import 'package:restaurant_booking_app/domain/entities/reservation.dart';
import 'package:restaurant_booking_app/domain/repositories/payment_repository.dart';
import 'package:restaurant_booking_app/domain/repositories/booking_repository.dart';
import 'package:restaurant_booking_app/domain/services/preorder_payment_service.dart';
import 'package:restaurant_booking_app/domain/services/payment_security_service.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';

import 'payment_integration_test.mocks.dart';

@GenerateMocks([PaymentRepository, BookingRepository])
void main() {
  group('Payment Integration Tests', () {
    late MockPaymentRepository mockPaymentRepository;
    late MockBookingRepository mockBookingRepository;
    late PreorderPaymentService preorderPaymentService;
    late PaymentSecurityService paymentSecurityService;

    setUp(() {
      mockPaymentRepository = MockPaymentRepository();
      mockBookingRepository = MockBookingRepository();
      preorderPaymentService = PreorderPaymentService(
        mockPaymentRepository,
        mockBookingRepository,
      );
      paymentSecurityService = PaymentSecurityService();
    });

    group('Preorder Payment Integration', () {
      test('should process complete preorder payment flow successfully',
          () async {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1500.0,
          method: PaymentMethod.card,
        );

        final preorderItems = [
          const PreorderItem(
            menuItemId: 'item_1',
            name: 'Паста Карбонара',
            quantity: 2,
            price: 750.0,
            notes: 'Без бекона',
            modifiers: ['mod_1'],
          ),
        ];

        const paymentResult = PaymentResult.success(
          transactionId: 'txn_123',
        );

        when(mockPaymentRepository.processPayment(paymentRequest))
            .thenAnswer((_) async => const ApiResult.success(paymentResult));

        // Act
        final result = await preorderPaymentService.processPreorderPayment(
          paymentRequest: paymentRequest,
          preorderItems: preorderItems,
          venueId: 'venue_123',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.paymentResult?.transactionId, 'txn_123');
        expect(result.preorderItems, preorderItems);
        expect(result.stage, PaymentStage.completed);
        verify(mockPaymentRepository.processPayment(paymentRequest)).called(1);
      });

      test('should handle payment validation failure', () async {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: -100.0, // Invalid amount
          method: PaymentMethod.card,
        );

        final preorderItems = [
          const PreorderItem(
            menuItemId: 'item_1',
            name: 'Test Item',
            quantity: 1,
            price: 100.0,
          ),
        ];

        // Act
        final result = await preorderPaymentService.processPreorderPayment(
          paymentRequest: paymentRequest,
          preorderItems: preorderItems,
          venueId: 'venue_123',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.stage, PaymentStage.validation);
        expect(result.error, contains('больше нуля'));
        verifyNever(mockPaymentRepository.processPayment(any));
      });

      test('should handle payment processing failure', () async {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1500.0,
          method: PaymentMethod.card,
        );

        final preorderItems = [
          const PreorderItem(
            menuItemId: 'item_1',
            name: 'Test Item',
            quantity: 1,
            price: 1500.0,
          ),
        ];

        const paymentResult = PaymentResult.failure(
          errorMessage: 'Insufficient funds',
        );

        when(mockPaymentRepository.processPayment(paymentRequest))
            .thenAnswer((_) async => const ApiResult.success(paymentResult));

        // Act
        final result = await preorderPaymentService.processPreorderPayment(
          paymentRequest: paymentRequest,
          preorderItems: preorderItems,
          venueId: 'venue_123',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.stage, PaymentStage.payment);
        expect(result.error, 'Insufficient funds');
        verify(mockPaymentRepository.processPayment(paymentRequest)).called(1);
      });

      test(
          'should create reservation with preorder when no existing reservation',
          () async {
        // Arrange
        const paymentRequest = PaymentRequest(
          orderId: 'order_123',
          amount: 1500.0,
          method: PaymentMethod.sbp,
        );

        final preorderItems = [
          const PreorderItem(
            menuItemId: 'item_1',
            name: 'Test Item',
            quantity: 1,
            price: 1500.0,
          ),
        ];

        final reservationRequest = ReservationRequest(
          venueId: 'venue_123',
          dateTime: DateTime.now().add(const Duration(hours: 2)),
          partySize: 2,
          preorderItems: preorderItems,
        );

        const paymentResult = PaymentResult.success(
          transactionId: 'txn_123',
        );

        final reservation = Reservation(
          id: 'reservation_123',
          userId: 'user_123',
          venueId: 'venue_123',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 4)),
          partySize: 2,
          status: ReservationStatus.confirmed,
          preorderItems: preorderItems,
          createdAt: DateTime.now(),
        );

        when(mockPaymentRepository.processPayment(paymentRequest))
            .thenAnswer((_) async => const ApiResult.success(paymentResult));

        when(mockBookingRepository.createReservation(any))
            .thenAnswer((_) async => ApiResult.success(reservation));

        // Act
        final result = await preorderPaymentService.processPreorderPayment(
          paymentRequest: paymentRequest,
          preorderItems: preorderItems,
          venueId: 'venue_123',
          reservationRequest: reservationRequest,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.reservationId, 'reservation_123');
        expect(result.stage, PaymentStage.completed);
        verify(mockPaymentRepository.processPayment(paymentRequest)).called(1);
        verify(mockBookingRepository.createReservation(any)).called(1);
      });
    });

    group('Payment Security Tests', () {
      test('should validate payment security successfully', () {
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

      test('should generate fiscal receipt data', () {
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
        expect(fiscalData.items, hasLength(1));
        expect(fiscalData.items.first.name, 'Паста Карбонара');
        expect(fiscalData.items.first.vatRate, 0.20);
        expect(fiscalData.paymentMethod, 'БЕЗНАЛИЧНЫМИ');
      });
    });

    group('QR Payment Tests', () {
      test('should resolve QR token successfully', () async {
        // Arrange
        const token = 'qr_token_123';
        final expectedSession = QRPaymentSession(
          token: token,
          tableId: 'table_5',
          venueId: 'venue_123',
          isActive: true,
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        when(mockPaymentRepository.resolveQRToken(token))
            .thenAnswer((_) async => ApiResult.success(expectedSession));

        // Act
        final result = await mockPaymentRepository.resolveQRToken(token);

        // Assert
        result.when(
          success: (session) {
            expect(session.token, token);
            expect(session.tableId, 'table_5');
            expect(session.isActive, true);
          },
          failure: (error) => fail('Should not fail'),
        );
        verify(mockPaymentRepository.resolveQRToken(token)).called(1);
      });

      test('should process QR payment successfully', () async {
        // Arrange
        const qrRequest = QRPaymentRequest(
          token: 'qr_token_123',
          amount: 2500.0,
          method: PaymentMethod.sbp,
        );

        const expectedResult = PaymentResult.success(
          transactionId: 'qr_txn_123',
        );

        when(mockPaymentRepository.processQRPayment(qrRequest))
            .thenAnswer((_) async => const ApiResult.success(expectedResult));

        // Act
        final result = await mockPaymentRepository.processQRPayment(qrRequest);

        // Assert
        result.when(
          success: (paymentResult) {
            expect(paymentResult.isSuccess, true);
            expect(paymentResult.transactionId, 'qr_txn_123');
          },
          failure: (error) => fail('Should not fail'),
        );
        verify(mockPaymentRepository.processQRPayment(qrRequest)).called(1);
      });
    });

    group('Payment Method Support', () {
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

      test('should calculate processing fees correctly', () {
        // Act
        final sbpFee = preorderPaymentService.calculateProcessingFee(
          PaymentMethod.sbp,
          1000.0,
        );
        final cardFee = preorderPaymentService.calculateProcessingFee(
          PaymentMethod.card,
          1000.0,
        );

        // Assert
        expect(sbpFee, 5.0); // 0.5% of 1000
        expect(cardFee, 25.0); // 2.5% of 1000
      });

      test('should provide estimated processing times', () {
        // Act
        final sbpTime = preorderPaymentService.getEstimatedProcessingTime(
          PaymentMethod.sbp,
        );
        final cardTime = preorderPaymentService.getEstimatedProcessingTime(
          PaymentMethod.card,
        );

        // Assert
        expect(sbpTime, const Duration(seconds: 30));
        expect(cardTime, const Duration(minutes: 2));
      });
    });

    group('Receipt Generation', () {
      test('should get receipt for successful payment', () async {
        // Arrange
        const paymentId = 'payment_123';
        final expectedReceipt = Receipt(
          id: 'receipt_123',
          orderId: 'order_123',
          fiscalNumber: 'FN123456',
          timestamp: DateTime.now(),
          amount: 1500.0,
          qrCode: 'receipt_qr_code',
          pdfUrl: 'https://example.com/receipt.pdf',
        );

        when(mockPaymentRepository.getReceipt(paymentId))
            .thenAnswer((_) async => ApiResult.success(expectedReceipt));

        // Act
        final result = await mockPaymentRepository.getReceipt(paymentId);

        // Assert
        result.when(
          success: (receipt) {
            expect(receipt.id, 'receipt_123');
            expect(receipt.fiscalNumber, 'FN123456');
            expect(receipt.amount, 1500.0);
            expect(receipt.pdfUrl, 'https://example.com/receipt.pdf');
          },
          failure: (error) => fail('Should not fail'),
        );
        verify(mockPaymentRepository.getReceipt(paymentId)).called(1);
      });
    });
  });
}
