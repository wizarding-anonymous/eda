import 'package:equatable/equatable.dart';

/// Represents a time slot for booking at a venue
class TimeSlot extends Equatable {
  final String id;
  final String venueId;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCapacity;
  final int currentBookings;
  final bool isAvailable;
  final double? depositRequired;
  final String? tableType;
  final Map<String, dynamic>? restrictions;

  const TimeSlot({
    required this.id,
    required this.venueId,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    this.currentBookings = 0,
    this.isAvailable = true,
    this.depositRequired,
    this.tableType,
    this.restrictions,
  });

  /// Duration of the time slot in minutes
  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  /// Available capacity for new bookings
  int get availableCapacity => maxCapacity - currentBookings;

  /// Check if the time slot can accommodate the requested party size
  bool canAccommodate(int partySize) {
    return isAvailable && availableCapacity >= partySize;
  }

  /// Check if the time slot is in the past
  bool get isPast => startTime.isBefore(DateTime.now());

  /// Check if the time slot is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      venueId: json['venue_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      maxCapacity: json['max_capacity'],
      currentBookings: json['current_bookings'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      depositRequired: json['deposit_required']?.toDouble(),
      tableType: json['table_type'],
      restrictions: json['restrictions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'max_capacity': maxCapacity,
      'current_bookings': currentBookings,
      'is_available': isAvailable,
      'deposit_required': depositRequired,
      'table_type': tableType,
      'restrictions': restrictions,
    };
  }

  TimeSlot copyWith({
    String? id,
    String? venueId,
    DateTime? startTime,
    DateTime? endTime,
    int? maxCapacity,
    int? currentBookings,
    bool? isAvailable,
    double? depositRequired,
    String? tableType,
    Map<String, dynamic>? restrictions,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentBookings: currentBookings ?? this.currentBookings,
      isAvailable: isAvailable ?? this.isAvailable,
      depositRequired: depositRequired ?? this.depositRequired,
      tableType: tableType ?? this.tableType,
      restrictions: restrictions ?? this.restrictions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        venueId,
        startTime,
        endTime,
        maxCapacity,
        currentBookings,
        isAvailable,
        depositRequired,
        tableType,
        restrictions,
      ];
}

/// Request model for querying available time slots
class TimeSlotQuery extends Equatable {
  final String venueId;
  final DateTime date;
  final int partySize;
  final String? tableType;
  final Duration? preferredDuration;

  const TimeSlotQuery({
    required this.venueId,
    required this.date,
    required this.partySize,
    this.tableType,
    this.preferredDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'venue_id': venueId,
      'date': date.toIso8601String(),
      'party_size': partySize,
      'table_type': tableType,
      'preferred_duration': preferredDuration?.inMinutes,
    };
  }

  @override
  List<Object?> get props => [
        venueId,
        date,
        partySize,
        tableType,
        preferredDuration,
      ];
}
