import 'package:equatable/equatable.dart';

/// Represents a table in a venue
class Table extends Equatable {
  final String id;
  final String venueId;
  final String name;
  final int minCapacity;
  final int maxCapacity;
  final TableType type;
  final TableLocation location;
  final List<String> amenities;
  final bool isActive;
  final double? reservationFee;
  final Map<String, dynamic>? metadata;

  const Table({
    required this.id,
    required this.venueId,
    required this.name,
    required this.minCapacity,
    required this.maxCapacity,
    required this.type,
    required this.location,
    this.amenities = const [],
    this.isActive = true,
    this.reservationFee,
    this.metadata,
  });

  /// Check if the table can accommodate the requested party size
  bool canAccommodate(int partySize) {
    return isActive && partySize >= minCapacity && partySize <= maxCapacity;
  }

  /// Check if the table has a specific amenity
  bool hasAmenity(String amenity) {
    return amenities.contains(amenity);
  }

  /// Get display name for the table
  String get displayName {
    return '${type.displayName} $name';
  }

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      venueId: json['venue_id'],
      name: json['name'],
      minCapacity: json['min_capacity'],
      maxCapacity: json['max_capacity'],
      type: TableType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TableType.standard,
      ),
      location: TableLocation.values.firstWhere(
        (e) => e.name == json['location'],
        orElse: () => TableLocation.indoor,
      ),
      amenities: List<String>.from(json['amenities'] ?? []),
      isActive: json['is_active'] ?? true,
      reservationFee: json['reservation_fee']?.toDouble(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'name': name,
      'min_capacity': minCapacity,
      'max_capacity': maxCapacity,
      'type': type.name,
      'location': location.name,
      'amenities': amenities,
      'is_active': isActive,
      'reservation_fee': reservationFee,
      'metadata': metadata,
    };
  }

  Table copyWith({
    String? id,
    String? venueId,
    String? name,
    int? minCapacity,
    int? maxCapacity,
    TableType? type,
    TableLocation? location,
    List<String>? amenities,
    bool? isActive,
    double? reservationFee,
    Map<String, dynamic>? metadata,
  }) {
    return Table(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      minCapacity: minCapacity ?? this.minCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      type: type ?? this.type,
      location: location ?? this.location,
      amenities: amenities ?? this.amenities,
      isActive: isActive ?? this.isActive,
      reservationFee: reservationFee ?? this.reservationFee,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        venueId,
        name,
        minCapacity,
        maxCapacity,
        type,
        location,
        amenities,
        isActive,
        reservationFee,
        metadata,
      ];
}

/// Types of tables available in venues
enum TableType {
  standard('Обычный'),
  vip('VIP'),
  booth('Кабинка'),
  bar('Барная стойка'),
  outdoor('Летняя веранда'),
  private('Приватная зона');

  const TableType(this.displayName);
  final String displayName;
}

/// Location of the table within the venue
enum TableLocation {
  indoor('В помещении'),
  outdoor('На улице'),
  terrace('Терраса'),
  balcony('Балкон'),
  window('У окна'),
  center('В центре зала'),
  corner('В углу'),
  bar('У бара');

  const TableLocation(this.displayName);
  final String displayName;
}

/// Request model for querying available tables
class TableQuery extends Equatable {
  final String venueId;
  final int partySize;
  final TableType? preferredType;
  final TableLocation? preferredLocation;
  final List<String>? requiredAmenities;
  final DateTime? dateTime;

  const TableQuery({
    required this.venueId,
    required this.partySize,
    this.preferredType,
    this.preferredLocation,
    this.requiredAmenities,
    this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'venue_id': venueId,
      'party_size': partySize,
      'preferred_type': preferredType?.name,
      'preferred_location': preferredLocation?.name,
      'required_amenities': requiredAmenities,
      'date_time': dateTime?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        venueId,
        partySize,
        preferredType,
        preferredLocation,
        requiredAmenities,
        dateTime,
      ];
}

/// Represents table availability for a specific time period
class TableAvailability extends Equatable {
  final Table table;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? unavailableReason;
  final double? dynamicPricing;

  const TableAvailability({
    required this.table,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.unavailableReason,
    this.dynamicPricing,
  });

  /// Total cost for reserving this table (base fee + dynamic pricing)
  double get totalCost {
    final baseFee = table.reservationFee ?? 0.0;
    final dynamicFee = dynamicPricing ?? 0.0;
    return baseFee + dynamicFee;
  }

  factory TableAvailability.fromJson(Map<String, dynamic> json) {
    return TableAvailability(
      table: Table.fromJson(json['table']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isAvailable: json['is_available'],
      unavailableReason: json['unavailable_reason'],
      dynamicPricing: json['dynamic_pricing']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table': table.toJson(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_available': isAvailable,
      'unavailable_reason': unavailableReason,
      'dynamic_pricing': dynamicPricing,
    };
  }

  TableAvailability copyWith({
    Table? table,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    String? unavailableReason,
    double? dynamicPricing,
  }) {
    return TableAvailability(
      table: table ?? this.table,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableReason: unavailableReason ?? this.unavailableReason,
      dynamicPricing: dynamicPricing ?? this.dynamicPricing,
    );
  }

  @override
  List<Object?> get props => [
        table,
        startTime,
        endTime,
        isAvailable,
        unavailableReason,
        dynamicPricing,
      ];
}
