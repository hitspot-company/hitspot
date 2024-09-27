import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/src/models/hs_place_details.dart';
import 'package:hs_location_repository/src/models/hs_prediction.dart';
import 'package:map_launcher/map_launcher.dart' as ml;
import 'package:uuid/uuid.dart';

enum HSSpotMarkerType { verified, unverified, selected }

class HSLocationRepository {
  HSLocationRepository(String googleMapsApiKey, String placesApiKey) {
    this.googleMapsApiKey = googleMapsApiKey;
    this.placesApiKey = placesApiKey;
  }

  final Dio _dio = Dio();
  late final String googleMapsApiKey, placesApiKey;

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

      final locationData = await Geolocator.getCurrentPosition(
              timeLimit: const Duration(seconds: 3))
          .onError((a, v) => throw "Reached time limit.");
      return locationData;
    } catch (_) {
      throw 'Location service is disabled or could not be fetched: $_';
    }
  }

  Future<String> getAddress(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      if (placemarks.isEmpty) {
        return 'No address found';
      }

      Placemark placemark = placemarks.reversed.last;

      // Helper function to clean and format address parts
      String formatPart(String? part) =>
          (part != null && part.isNotEmpty) ? part : '';

      // Extracting relevant parts from the placemark
      List<String> addressParts = [
        formatPart(placemark.street),
        formatPart(placemark.subLocality),
        formatPart(placemark.locality),
        formatPart(placemark.subAdministrativeArea),
        formatPart(placemark.administrativeArea),
        formatPart(placemark.postalCode),
        formatPart(placemark.country),
      ];

      // Remove duplicates and empty parts
      addressParts =
          addressParts.toSet().where((part) => part.isNotEmpty).toList();

      // Join parts with ', '
      String address = addressParts.join(', ');

      print("Your Address for ($lat, $long) is: $address");

      return address;
    } catch (error) {
      throw "Could not fetch address: $error";
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

  Future<List<HSPrediction>> fetchPredictions(String query, String uid) async {
    final String sessionToken = Uuid().v4();

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      var response = await _dio.get(baseURL, queryParameters: {
        "input": query,
        "key": placesApiKey,
        "sessiontoken": sessionToken,
      });
      if (response.statusCode == 200) {
        List predictions = response.data['predictions'];
        final List<HSPrediction> res = [];
        for (var i = 0; i < predictions.length; i++) {
          final HSPrediction pred = HSPrediction.deserialize(predictions[i]);
          res.add(pred);
        }

        return res;
      } else {
        throw 'Failed to load predictions';
      }
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }

  Future<HSPlaceDetails> fetchPlaceDetails({required String placeID}) async {
    try {
      final baseUrl = "https://maps.googleapis.com/maps/api/place/details/json";
      Response response = await _dio.get(baseUrl, queryParameters: {
        "placeid": placeID,
        "key": placesApiKey,
      });
      final result = response.data['result'];
      final address = result['formatted_address'];
      final location = result['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];
      final ref = result['reference'];
      return HSPlaceDetails(
        latitude: lat,
        longitude: lng,
        description: address,
        placeID: placeID,
        reference: ref,
      );
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  String encodeGeoHash(double lat, double long) {
    final GeoHasher geoHasher = GeoHasher();
    return geoHasher.encode(long, lat);
  }

  Map<String, String> fetchNeighbors(String? geohash, LatLng? latLng) {
    assert(geohash != null || latLng != null,
        "Either a geoHash or latLng is required");
    try {
      late final GeoHash hash;
      if (geohash != null) {
        hash = GeoHash(geohash);
      } else {
        GeoHash.fromDecimalDegrees(latLng!.longitude, latLng.latitude);
      }
      return hash.neighbors;
    } catch (_) {
      throw Exception("Could not fetch neighbors : $_");
    }
  }

  Future<void> launchMaps(
      {required String title,
      required String description,
      required LatLng coords}) async {
    final List<ml.AvailableMap> availableMaps =
        await ml.MapLauncher.installedMaps;
    late final ml.MapType preferredMapType;
    if (availableMaps.contains(ml.MapType.google)) {
      preferredMapType = ml.MapType.google;
    } else if (availableMaps.contains(ml.MapType.apple)) {
      preferredMapType = ml.MapType.apple;
    } else {
      preferredMapType = availableMaps.first.mapType;
    }
    final ml.Coords launchCoords = ml.Coords(coords.latitude, coords.longitude);
    await ml.MapLauncher.showMarker(
        coords: launchCoords,
        title: title,
        description: description,
        mapType: preferredMapType);
  }

  double distanceBetween(
      {HSSpot? spot1,
      HSSpot? spot2,
      double? lat1,
      double? lat2,
      double? long1,
      double? long2}) {
    assert(spot1 != null || (lat1 != null && long1 != null),
        "Either spot1 or lat1 and long1 are required");

    assert(spot2 != null || (lat2 != null && long2 != null),
        "Either spot2 or lat2 and long2 are required");
    final startLat = lat1 ?? spot1!.latitude!;
    final startLong = long1 ?? spot1!.longitude!;
    final endLat = lat2 ?? spot2!.latitude!;
    final endLong = long2 ?? spot2!.longitude!;
    return Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
  }

  Future<void> animateCameraToNewLatLng(
      Completer<GoogleMapController> mapController, LatLng location,
      [double? zoom]) async {
    late final double zoomLevel;
    final GoogleMapController controller = await mapController.future;
    if (Platform.isAndroid) {
      zoomLevel = zoom ?? 16.0;
    } else {
      zoomLevel = zoom ?? await controller.getZoomLevel();
    }
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        location,
        zoomLevel,
      ),
    );
  }

  Future<void> zoomToFitSpots(
      List<HSSpot> spots, GoogleMapController controller,
      {Position? currentPosition}) async {
    if (spots.isEmpty) return;

    List<LatLng> spotPositions =
        spots.map((e) => LatLng(e.latitude!, e.longitude!)).toList();

    if (currentPosition != null) {
      spotPositions
          .add(LatLng(currentPosition.latitude, currentPosition.longitude));
    }

    LatLngBounds bounds = _getLatLngBounds(spotPositions);
    LatLng center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    double zoom = 21; // Start with maximum zoom
    bool allVisible = false;

    while (!allVisible && zoom > 0) {
      await controller.moveCamera(CameraUpdate.newLatLngZoom(center, zoom));
      LatLngBounds visibleRegion = await controller.getVisibleRegion();

      allVisible = spotPositions.every((spot) =>
          spot.latitude >= visibleRegion.southwest.latitude &&
          spot.latitude <= visibleRegion.northeast.latitude &&
          spot.longitude >= visibleRegion.southwest.longitude &&
          spot.longitude <= visibleRegion.northeast.longitude);

      if (!allVisible) zoom -= 0.5;
    }

    // Add a little padding
    await controller.moveCamera(CameraUpdate.newLatLngZoom(center, zoom - .6));
  }

  // Calculate LatLngBounds that includes all the spots
  LatLngBounds _getLatLngBounds(List<LatLng> spots) {
    double minLat = spots[0].latitude;
    double maxLat = spots[0].latitude;
    double minLng = spots[0].longitude;
    double maxLng = spots[0].longitude;

    for (LatLng spot in spots) {
      if (spot.latitude < minLat) minLat = spot.latitude;
      if (spot.latitude > maxLat) maxLat = spot.latitude;
      if (spot.longitude < minLng) minLng = spot.longitude;
      if (spot.longitude > maxLng) maxLng = spot.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void resetPosition(Completer<GoogleMapController> controller,
      [Position? currentPosition]) async {
    late final Position pos;
    if (currentPosition == null) {
      pos = await getCurrentLocation();
    } else {
      pos = currentPosition;
    }
    await animateCameraToNewLatLng(
        controller, LatLng(pos.latitude, pos.longitude), 13);
  }
}
