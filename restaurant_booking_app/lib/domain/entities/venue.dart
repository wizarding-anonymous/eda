import 'package:equatable/equatable.dart';

class Venue extends Equatable {
  final String id;
  final String name;
  final String description;
  final Address address;
  final LatLng coordinates;
  final List<String> photos;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final String cuisine;
  final PriceLevel priceLevel;
  final OpeningHours openingHours;
  final List<Amenity> amenities;
  final bool isOpen;
  final double? distance; // Distance from user in km

  const Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.coordinates,
    required this.photos,
    required this.rating,
    required this.reviewCount,
    required this.categories,
    required this.cuisine,
    required this.priceLevel,
    required this.openingHours,
    required this.amenities,
    required this.isOpen,
    this.distance,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        coordinates,
        photos,
        rating,
        reviewCount,
        categories,
        cuisine,
        priceLevel,
        openingHours,
        amenities,
        isOpen,
        distance,
      ];

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      coordinates: LatLng.fromJson(json['coordinates'] as Map<String, dynamic>),
      photos: List<String>.from(json['photos'] as List? ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      categories: List<String>.from(json['categories'] as List? ?? []),
      cuisine: json['cuisine'] as String? ?? '',
      priceLevel: PriceLevel.values[json['price_level'] as int? ?? 0],
      openingHours: OpeningHours.fromJson(
          json['opening_hours'] as Map<String, dynamic>? ?? {}),
      amenities: (json['amenities'] as List?)
              ?.map((e) => Amenity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isOpen: json['is_open'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address.toJson(),
      'coordinates': coordinates.toJson(),
      'photos': photos,
      'rating': rating,
      'review_count': reviewCount,
      'categories': categories,
      'cuisine': cuisine,
      'price_level': priceLevel.index,
      'opening_hours': openingHours.toJson(),
      'amenities': amenities.map((e) => e.toJson()).toList(),
      'is_open': isOpen,
      if (distance != null) 'distance': distance,
    };
  }
}

class Address extends Equatable {
  final String street;
  final String city;
  final String? building;
  final String? apartment;
  final String? district;

  const Address({
    required this.street,
    required this.city,
    this.building,
    this.apartment,
    this.district,
  });

  @override
  List<Object?> get props => [street, city, building, apartment, district];

  String get fullAddress {
    final parts = <String>[
      if (building != null) building!,
      street,
      if (district != null) district!,
      city,
    ];
    return parts.join(', ');
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      city: json['city'] as String,
      building: json['building'] as String?,
      apartment: json['apartment'] as String?,
      district: json['district'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      if (building != null) 'building': building,
      if (apartment != null) 'apartment': apartment,
      if (district != null) 'district': district,
    };
  }
}

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

enum PriceLevel { budget, moderate, expensive, luxury }

class OpeningHours extends Equatable {
  final Map<String, DayHours> hours;
  final bool isOpen24Hours;

  const OpeningHours({
    required this.hours,
    this.isOpen24Hours = false,
  });

  @override
  List<Object> get props => [hours, isOpen24Hours];

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    final hoursMap = <String, DayHours>{};
    final hoursData = json['hours'] as Map<String, dynamic>? ?? {};

    for (final entry in hoursData.entries) {
      hoursMap[entry.key] =
          DayHours.fromJson(entry.value as Map<String, dynamic>);
    }

    return OpeningHours(
      hours: hoursMap,
      isOpen24Hours: json['is_open_24_hours'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hours': hours.map((key, value) => MapEntry(key, value.toJson())),
      'is_open_24_hours': isOpen24Hours,
    };
  }
}

class DayHours extends Equatable {
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  const DayHours({
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [openTime, closeTime, isClosed];

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (openTime != null) 'open_time': openTime,
      if (closeTime != null) 'close_time': closeTime,
      'is_closed': isClosed,
    };
  }
}

class Amenity extends Equatable {
  final String id;
  final String name;
  final String icon;

  const Amenity({
    required this.id,
    required this.name,
    required this.icon,
  });

  @override
  List<Object> get props => [id, name, icon];

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}

class SearchFilters extends Equatable {
  final String? query;
  final List<String> categories;
  final List<String> cuisines;
  final double? maxDistance;
  final LatLng? location;
  final bool openNow;
  final PriceLevel? priceLevel; // Changed from maxPriceLevel to priceLevel
  final double? minRating;
  final List<Amenity> amenities; // Changed from List<String> to List<Amenity>

  const SearchFilters({
    this.query,
    this.categories = const [],
    this.cuisines = const [],
    this.maxDistance,
    this.location,
    this.openNow = false,
    this.priceLevel, // Changed from maxPriceLevel to priceLevel
    this.minRating,
    this.amenities = const [],
  });

  @override
  List<Object?> get props => [
        query,
        categories,
        cuisines,
        maxDistance,
        location,
        openNow,
        priceLevel, // Changed from maxPriceLevel to priceLevel
        minRating,
        amenities,
      ];

  SearchFilters copyWith({
    String? query,
    List<String>? categories,
    List<String>? cuisines,
    double? maxDistance,
    LatLng? location,
    bool? openNow,
    PriceLevel? priceLevel,
    double? minRating,
    List<Amenity>? amenities,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      cuisines: cuisines ?? this.cuisines,
      maxDistance: maxDistance ?? this.maxDistance,
      location: location ?? this.location,
      openNow: openNow ?? this.openNow,
      priceLevel: priceLevel ?? this.priceLevel,
      minRating: minRating ?? this.minRating,
      amenities: amenities ?? this.amenities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (query != null) 'query': query,
      if (categories.isNotEmpty) 'categories': categories,
      if (cuisines.isNotEmpty) 'cuisines': cuisines,
      if (maxDistance != null) 'max_distance': maxDistance,
      if (location != null) 'location': location!.toJson(),
      'open_now': openNow,
      if (priceLevel != null) 'price_level': priceLevel!.index,
      if (minRating != null) 'min_rating': minRating,
      if (amenities.isNotEmpty)
        'amenities': amenities.map((a) => a.toJson()).toList(),
    };
  }
}

class TimeSlot extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int availableSeats;
  final int totalSeats;
  final bool isAvailable;
  final double? price; // Optional price for premium time slots

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.isAvailable,
    this.price,
  });

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        availableSeats,
        totalSeats,
        isAvailable,
        price,
      ];

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      availableSeats: json['available_seats'] as int,
      totalSeats: json['total_seats'] as int,
      isAvailable: json['is_available'] as bool? ?? true,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'available_seats': availableSeats,
      'total_seats': totalSeats,
      'is_available': isAvailable,
      if (price != null) 'price': price,
    };
  }

  /// Returns the duration of this time slot
  Duration get duration => endTime.difference(startTime);

  /// Returns true if this slot is fully booked
  bool get isFullyBooked => availableSeats <= 0;

  /// Returns the occupancy percentage (0.0 to 1.0)
  double get occupancyRate =>
      totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;
}
