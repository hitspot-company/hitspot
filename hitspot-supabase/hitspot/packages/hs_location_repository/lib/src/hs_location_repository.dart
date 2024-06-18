// import 'dart:async';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'dart:math' show cos, sqrt, asin;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HSLocationRepository {
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        final result = await Geolocator.openLocationSettings();
        if (!result) {
          return Future.error('Location service is disabled');
        }
      }

      final locationData = await Geolocator.getCurrentPosition();
      return locationData;
    } catch (_) {
      throw 'Location service is disabled : $_';
    }
  }

  Future<String> getAddress(double lat, double long) async {
    try {
      final Placemark placemark = await getPlacemark(lat, long);
      return placemark.name ?? 'Unknown';
    } catch (_) {
      throw "Could not fetch address : $_";
    }
  }

  Future<Placemark> getPlacemark(double lat, double long) async {
    try {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(lat, long);
      return placemarks.first;
    } catch (_) {
      throw "Could not fetch placemark : $_";
    }
  }
}
