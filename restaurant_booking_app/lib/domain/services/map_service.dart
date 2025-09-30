import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../entities/venue.dart';
import '../../core/config/env_config.dart';

abstract class MapService {
  Future<void> initialize();
  Point convertToYandexPoint(LatLng latLng);
  LatLng convertFromYandexPoint(Point point);
  List<MapObject> createVenueMarkers(List<Venue> venues,
      {Function(Venue)? onVenueTap});
  CameraPosition createCameraPosition(LatLng center, {double zoom = 14.0});
}

class MapServiceImpl implements MapService {
  @override
  Future<void> initialize() async {
    // Initialize Yandex MapKit
    AndroidYandexMap.useAndroidViewSurface;

    // Set API key if available
    if (EnvConfig.hasValidYandexMapsApiKey) {
      // TODO: Uncomment when ready to use real API key
      // MapKit.setApiKey(EnvConfig.yandexMapsApiKey);
    } else if (EnvConfig.isDevelopment) {
      // In development, log a warning about missing API key
      debugPrint('Warning: Yandex Maps API key not configured. '
          'Set YANDEX_MAPS_API_KEY environment variable.');
    }
  }

  @override
  Point convertToYandexPoint(LatLng latLng) {
    return Point(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }

  @override
  LatLng convertFromYandexPoint(Point point) {
    return LatLng(
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }

  @override
  List<MapObject> createVenueMarkers(
    List<Venue> venues, {
    Function(Venue)? onVenueTap,
  }) {
    return venues.map((venue) {
      return PlacemarkMapObject(
        mapId: MapObjectId('venue_${venue.id}'),
        point: convertToYandexPoint(venue.coordinates),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage(
              'assets/images/restaurant_marker.png',
            ),
            scale: 0.8,
          ),
        ),
        text: PlacemarkText(
          text: venue.name,
          style: const PlacemarkTextStyle(
            size: 12,
            color: Colors.black,
            outlineColor: Colors.white,
            placement: TextStylePlacement.bottom,
          ),
        ),
        onTap: (PlacemarkMapObject placemark, Point point) {
          onVenueTap?.call(venue);
        },
      );
    }).toList();
  }

  @override
  CameraPosition createCameraPosition(LatLng center, {double zoom = 14.0}) {
    return CameraPosition(
      target: convertToYandexPoint(center),
      zoom: zoom,
    );
  }
}
