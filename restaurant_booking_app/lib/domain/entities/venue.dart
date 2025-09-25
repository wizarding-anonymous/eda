import 'package:equatable/equatable.dart';

class Venue extends Equatable {
  final String id;
  final String name;
  final String description;
  final Address address;
  final LatLng coordinates;
  final List<String> photos;
  final double rating;
  final List<String> categories;
  final String cuisine;
  final PriceLevel priceLevel;
  final OpeningHours openingHours;
  final List<Amenity> amenities;

  const Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.coordinates,
    required this.photos,
    required this.rating,
    required this.categories,
    required this.cuisine,
    required this.priceLevel,
    required this.openingHours,
    required this.amenities,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: Address.fromJson(json['address']),
      coordinates: LatLng.fromJson(json['coordinates']),
      photos: List<String>.from(json['photos'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      cuisine: json['cuisine'],
      priceLevel: PriceLevel.values.firstWhere(
        (e) => e.name == json['price_level'],
        orElse: () => PriceLevel.moderate,
      ),
      openingHours: OpeningHours.fromJson(json['opening_hours']),
      amenities: (json['amenities'] as List?)
              ?.map((a) => Amenity.values.firstWhere(
                    (e) => e.name == a,
                    orElse: () => Amenity.wifi,
                  ))
              .toList() ??
          [],
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
      'categories': categories,
      'cuisine': cuisine,
      'price_level': priceLevel.name,
      'opening_hours': openingHours.toJson(),
      'amenities': amenities.map((a) => a.name).toList(),
    };
  }

  @override
  List<Object> get props => [
        id,
        name,
        description,
        address,
        coordinates,
        photos,
        rating,
        categories,
        cuisine,
        priceLevel,
        openingHours,
        amenities,
      ];
}

class Address extends Equatable {
  final String street;
  final String city;
  final String? building;
  final String? apartment;

  const Address({
    required this.street,
    required this.city,
    this.building,
    this.apartment,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      building: json['building'],
      apartment: json['apartment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'building': building,
      'apartment': apartment,
    };
  }

  @override
  List<Object?> get props => [street, city, building, apartment];
}

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      latitude: (json['latitude'] ?? json['lat']).toDouble(),
      longitude: (json['longitude'] ?? json['lng']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object> get props => [latitude, longitude];
}

enum PriceLevel { budget, moderate, expensive, luxury }

class OpeningHours extends Equatable {
  final Map<int, DaySchedule> schedule; // 1-7 for Monday-Sunday

  const OpeningHours({required this.schedule});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    final schedule = <int, DaySchedule>{};
    json.forEach((key, value) {
      final dayNumber = int.tryParse(key);
      if (dayNumber != null) {
        schedule[dayNumber] = DaySchedule.fromJson(value);
      }
    });
    return OpeningHours(schedule: schedule);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    schedule.forEach((key, value) {
      json[key.toString()] = value.toJson();
    });
    return json;
  }

  @override
  List<Object> get props => [schedule];
}

class DaySchedule extends Equatable {
  final bool isOpen;
  final List<TimeSlot> timeSlots;

  const DaySchedule({
    required this.isOpen,
    required this.timeSlots,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      isOpen: json['is_open'] ?? false,
      timeSlots: (json['time_slots'] as List?)
              ?.map((slot) => TimeSlot.fromJson(slot))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_open': isOpen,
      'time_slots': timeSlots.map((slot) => slot.toJson()).toList(),
    };
  }

  @override
  List<Object> get props => [isOpen, timeSlots];
}

class TimeSlot extends Equatable {
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format

  const TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  @override
  List<Object> get props => [startTime, endTime];
}

enum Amenity {
  wifi,
  parking,
  terrace,
  liveMusic,
  kidsArea,
  petFriendly,
  wheelchairAccessible,
  delivery,
  takeaway,
  cardPayment,
  cashOnly,
}

class SearchFilters extends Equatable {
  final String? query;
  final List<String> categories;
  final double? maxDistance;
  final LatLng? location;
  final bool openNow;
  final PriceLevel? priceLevel;
  final List<Amenity> amenities;

  const SearchFilters({
    this.query,
    this.categories = const [],
    this.maxDistance,
    this.location,
    this.openNow = false,
    this.priceLevel,
    this.amenities = const [],
  });

  @override
  List<Object?> get props => [
        query,
        categories,
        maxDistance,
        location,
        openNow,
        priceLevel,
        amenities,
      ];
}