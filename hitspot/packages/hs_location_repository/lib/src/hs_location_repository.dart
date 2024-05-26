import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

class HSLocationRepository {
  Location location = Location();
  bool isPermissionGranted = false;

  Future<bool> requestLocationPermission() async {
    final permission = await location.requestPermission();
    isPermissionGranted = permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited;
    return isPermissionGranted;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        final result = await location.requestService();
        if (!result) {
          return null;
        }
      }

      final locationData = await location.getLocation();
      return locationData;
    } catch (_) {
      requestLocationPermission();
      return null;
    }
  }
}
