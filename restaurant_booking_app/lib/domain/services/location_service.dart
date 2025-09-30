import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entities/venue.dart';

abstract class LocationService {
  Future<LatLng?> getCurrentLocation();
  Future<bool> requestLocationPermission();
  Future<bool> isLocationServiceEnabled();
  double calculateDistance(LatLng from, LatLng to);
  Future<void> openNavigation(LatLng destination, {String? destinationName});
}

class LocationServiceImpl implements LocationService {
  @override
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        return null;
      }

      // Check and request permission
      if (!await requestLocationPermission()) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LatLng(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // Handle errors (timeout, permission denied, etc.)
      return null;
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission denied forever, open app settings
        await openAppSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        ) /
        1000; // Convert to kilometers
  }

  @override
  Future<void> openNavigation(LatLng destination,
      {String? destinationName}) async {
    try {
      // Try to open Yandex Maps first
      final yandexUrl =
          'yandexmaps://maps.yandex.ru/?pt=${destination.longitude},${destination.latitude}&z=16&l=map';

      // If Yandex Maps is not available, try Google Maps
      final googleUrl =
          'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';

      // Try to open Yandex Maps first
      if (await canLaunchUrl(Uri.parse(yandexUrl))) {
        await launchUrl(
          Uri.parse(yandexUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // If Yandex Maps is not available, try Google Maps
      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrl(
          Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // Fallback to Apple Maps on iOS
      final appleMapsUrl =
          'http://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}';

      if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      throw Exception('No navigation app available');
    } catch (e) {
      // Handle navigation error
      throw Exception('Failed to open navigation: $e');
    }
  }
}
