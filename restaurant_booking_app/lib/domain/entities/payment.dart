import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String? userId;
  final String venueId;
  final String? reservationId;
  final OrderSource source;
  final OrderStatus status;
  final List<OrderItem> items;
  final OrderTotals totals;
  final DateTime createdAt;
  final DateTime? closedAt;

  const Order({
    required this.id,
    this.userId,
    required this.venueId,
    this.reservationId,
    required this.source,
    required this.status,
    required this.items,
    required this.totals,
    required this.createdAt,
    this.closedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      venueId: json['venue_id'],
      reservationId: json['reservation_id'],
      source: OrderSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => OrderSource.preorder,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totals: OrderTotals.fromJson(json['totals']),
      createdAt: DateTime.parse(json['created_at']),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'venue_id': venueId,
      'reservation_id': reservationId,
      'source': source.name,
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'totals': totals.toJson(),
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        venueId,
        reservationId,
        source,
        status,
        items,
        totals,
        createdAt,
        closedAt,
      ];
}

class OrderItem extends Equatable {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  final List<String> modifiers;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
    this.modifiers = const [],
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      menuItemId: json['menu_item_id'],
      name: json['name'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'].toDouble(),
      totalPrice: json['total_price'].toDouble(),
      notes: json['notes'],
      modifiers: List<String>.from(json['modifiers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'notes': notes,
      'modifiers': modifiers,
    };
  }

  @override
  List<Object?> get props => [
        id,
        menuItemId,
        name,
        quantity,
        unitPrice,
        totalPrice,
        notes,
        modifiers,
      ];
}

class OrderTotals extends Equatable {
  final double subtotal;
  final double discountTotal;
  final double tipTotal;
  final double serviceFee;
  final double taxTotal;
  final double total;

  const OrderTotals({
    required this.subtotal,
    required this.discountTotal,
    required this.tipTotal,
    required this.serviceFee,
    required this.taxTotal,
    required this.total,
  });

  factory OrderTotals.fromJson(Map<String, dynamic> json) {
    return OrderTotals(
      subtotal: json['subtotal'].toDouble(),
      discountTotal: json['discount_total'].toDouble(),
      tipTotal: json['tip_total'].toDouble(),
      serviceFee: json['service_fee'].toDouble(),
      taxTotal: json['tax_total'].toDouble(),
      total: json['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount_total': discountTotal,
      'tip_total': tipTotal,
      'service_fee': serviceFee,
      'tax_total': taxTotal,
      'total': total,
    };
  }

  @override
  List<Object> get props => [
        subtotal,
        discountTotal,
        tipTotal,
        serviceFee,
        taxTotal,
        total,
      ];
}

enum OrderSource { preorder, qr }
enum OrderStatus { pending, authorized, paid, cancelled, refunded }

class PaymentRequest extends Equatable {
  final String orderId;
  final double amount;
  final PaymentMethod method;
  final double? tip;
  final SplitMode? splitMode;

  const PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.method,
    this.tip,
    this.splitMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'amount': amount,
      'method': method.name,
      'tip': tip,
      'split_mode': splitMode?.name,
    };
  }

  @override
  List<Object?> get props => [orderId, amount, method, tip, splitMode];
}

class PaymentResult extends Equatable {
  final bool isSuccess;
  final String? transactionId;
  final String? errorMessage;
  final Receipt? receipt;

  const PaymentResult.success({
    required this.transactionId,
    this.receipt,
  })  : isSuccess = true,
        errorMessage = null;

  const PaymentResult.failure({required this.errorMessage})
      : isSuccess = false,
        transactionId = null,
        receipt = null;

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    if (json['is_success'] == true) {
      return PaymentResult.success(
        transactionId: json['transaction_id'],
        receipt: json['receipt'] != null ? Receipt.fromJson(json['receipt']) : null,
      );
    } else {
      return PaymentResult.failure(
        errorMessage: json['error_message'] ?? 'Payment failed',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'transaction_id': transactionId,
      'error_message': errorMessage,
      'receipt': receipt?.toJson(),
    };
  }

  @override
  List<Object?> get props => [isSuccess, transactionId, errorMessage, receipt];
}

class Receipt extends Equatable {
  final String id;
  final String orderId;
  final String fiscalNumber;
  final DateTime timestamp;
  final double amount;
  final String qrCode;
  final String pdfUrl;

  const Receipt({
    required this.id,
    required this.orderId,
    required this.fiscalNumber,
    required this.timestamp,
    required this.amount,
    required this.qrCode,
    required this.pdfUrl,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      orderId: json['order_id'],
      fiscalNumber: json['fiscal_number'],
      timestamp: DateTime.parse(json['timestamp']),
      amount: json['amount'].toDouble(),
      qrCode: json['qr_code'],
      pdfUrl: json['pdf_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'fiscal_number': fiscalNumber,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'qr_code': qrCode,
      'pdf_url': pdfUrl,
    };
  }

  @override
  List<Object> get props => [
        id,
        orderId,
        fiscalNumber,
        timestamp,
        amount,
        qrCode,
        pdfUrl,
      ];
}

enum PaymentMethod { card, sbp }
enum SplitMode { equal, byItems, custom }

class QRPaymentSession extends Equatable {
  final String token;
  final String tableId;
  final String venueId;
  final Order? currentOrder;
  final bool isActive;
  final DateTime expiresAt;

  const QRPaymentSession({
    required this.token,
    required this.tableId,
    required this.venueId,
    this.currentOrder,
    required this.isActive,
    required this.expiresAt,
  });

  factory QRPaymentSession.fromJson(Map<String, dynamic> json) {
    return QRPaymentSession(
      token: json['token'],
      tableId: json['table_id'],
      venueId: json['venue_id'],
      currentOrder: json['current_order'] != null 
          ? Order.fromJson(json['current_order']) 
          : null,
      isActive: json['is_active'] ?? false,
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'table_id': tableId,
      'venue_id': venueId,
      'current_order': currentOrder?.toJson(),
      'is_active': isActive,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        token,
        tableId,
        venueId,
        currentOrder,
        isActive,
        expiresAt,
      ];
}

class QRPaymentRequest extends Equatable {
  final String token;
  final double amount;
  final PaymentMethod method;
  final double? tip;
  final SplitMode? splitMode;

  const QRPaymentRequest({
    required this.token,
    required this.amount,
    required this.method,
    this.tip,
    this.splitMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'amount': amount,
      'method': method.name,
      'tip': tip,
      'split_mode': splitMode?.name,
    };
  }

  @override
  List<Object?> get props => [token, amount, method, tip, splitMode];
}

class PaymentHistory extends Equatable {
  final String id;
  final String orderId;
  final String venueId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? description;

  const PaymentHistory({
    required this.id,
    required this.orderId,
    required this.venueId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.description,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      orderId: json['order_id'],
      venueId: json['venue_id'],
      amount: json['amount'].toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.card,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'venue_id': venueId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        venueId,
        amount,
        method,
        status,
        createdAt,
        description,
      ];
}

enum PaymentStatus { pending, processing, completed, failed, cancelled }