import 'package:equatable/equatable.dart';

class Reservation extends Equatable {
  final String id;
  final String userId;
  final String venueId;
  final String? tableId;
  final DateTime startTime;
  final DateTime endTime;
  final int partySize;
  final ReservationStatus status;
  final String? notes;
  final double? prepaymentAmount;
  final List<PreorderItem> preorderItems;
  final DateTime createdAt;

  const Reservation({
    required this.id,
    required this.userId,
    required this.venueId,
    this.tableId,
    required this.startTime,
    required this.endTime,
    required this.partySize,
    required this.status,
    this.notes,
    this.prepaymentAmount,
    required this.preorderItems,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      venueId: json['venue_id'],
      tableId: json['table_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      partySize: json['party_size'],
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
      notes: json['notes'],
      prepaymentAmount: json['prepayment_amount']?.toDouble(),
      preorderItems: (json['preorder_items'] as List?)
              ?.map((item) => PreorderItem.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'venue_id': venueId,
      'table_id': tableId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'party_size': partySize,
      'status': status.name,
      'notes': notes,
      'prepayment_amount': prepaymentAmount,
      'preorder_items': preorderItems.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        venueId,
        tableId,
        startTime,
        endTime,
        partySize,
        status,
        notes,
        prepaymentAmount,
        preorderItems,
        createdAt,
      ];
}

enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  noShow,
  completed,
}

class ReservationRequest extends Equatable {
  final String venueId;
  final DateTime dateTime;
  final int partySize;
  final String? tableType;
  final String? notes;
  final List<PreorderItem>? preorderItems;

  const ReservationRequest({
    required this.venueId,
    required this.dateTime,
    required this.partySize,
    this.tableType,
    this.notes,
    this.preorderItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'venue_id': venueId,
      'date_time': dateTime.toIso8601String(),
      'party_size': partySize,
      'table_type': tableType,
      'notes': notes,
      'preorder_items': preorderItems?.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        venueId,
        dateTime,
        partySize,
        tableType,
        notes,
        preorderItems,
      ];
}

class PreorderItem extends Equatable {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final String? notes;
  final List<String> modifiers;

  const PreorderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.notes,
    this.modifiers = const [],
  });

  double get totalPrice => price * quantity;

  factory PreorderItem.fromJson(Map<String, dynamic> json) {
    return PreorderItem(
      menuItemId: json['menu_item_id'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      notes: json['notes'],
      modifiers: List<String>.from(json['modifiers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'notes': notes,
      'modifiers': modifiers,
    };
  }

  @override
  List<Object?> get props => [
        menuItemId,
        name,
        quantity,
        price,
        notes,
        modifiers,
      ];
}

class AvailableTimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? tableType;
  final double? depositRequired;

  const AvailableTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.tableType,
    this.depositRequired,
  });

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        isAvailable,
        tableType,
        depositRequired,
      ];
}