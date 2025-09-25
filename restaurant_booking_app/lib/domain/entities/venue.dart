import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue.freezed.dart';
part 'venue.g.dart';

@freezed
class Venue with _$Venue {
  const factory Venue({
    required String id,
    required String name,
    required String description,
    required Address address,
    required LatLng coordinates,
    required List<String> photos,
    required double rating,
    required List<String> categories,
    required String cuisine,
    required PriceLevel priceLevel,
    required OpeningHours openingHours,
    required List<Amenity> amenities,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
}

@freezed
class Address with _$Address {
  const factory Address({
    required String street,
    required String city,
    String? building,
    String? apartment,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}

@freezed
class LatLng with _$LatLng {
  const factory LatLng({
    required double latitude,
    required double longitude,
  }) = _LatLng;

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
}

enum PriceLevel {
  @JsonValue(1)
  cheap,
  @JsonValue(2)
  moderate,
  @JsonValue(3)
  expensive,
  @JsonValue(4)
  veryExpensive,
}

@freezed
class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    required bool openNow,
    required List<String> periods,
    required List<String> weekdayText,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) => _$OpeningHoursFromJson(json);
}

@freezed
class Amenity with _$Amenity {
  const factory Amenity({
    required String name,
    required String icon,
  }) = _Amenity;

  factory Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);
}

@freezed
class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    String? query,
    List<String>? categories,
    double? maxDistance,
    LatLng? location,
    @Default(false) bool openNow,
  }) = _SearchFilters;

  factory SearchFilters.fromJson(Map<String, dynamic> json) => _$SearchFiltersFromJson(json);
}