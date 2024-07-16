import 'dart:async';
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

      final locationData = await Geolocator.getCurrentPosition();
      return locationData;
    } catch (_) {
      throw 'Location service is disabled : $_';
    }
  }

  Future<String> getAddress(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      var address = '';

      if (placemarks.isNotEmpty) {
        // Concatenate non-null components of the address
        var streets = placemarks.reversed
            .map((placemark) => placemark.street)
            .where((street) => street != null && street != '');

        // Filter out unwanted parts
        streets = streets.where((street) =>
            street!.toLowerCase() !=
            placemarks.reversed.last.locality!
                .toLowerCase()); // Remove city names
        streets = streets
            .where((street) => !street!.contains('+')); // Remove street codes

        address += streets.join(', ');

        address += ', ${placemarks.reversed.last.subLocality ?? ''}';
        address += ', ${placemarks.reversed.last.locality ?? ''}';
        address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.postalCode ?? ''}';
        address += ', ${placemarks.reversed.last.country ?? ''}';
      }

      print("Your Address for ($lat, $long) is: $address");

      return address;
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
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        location,
        zoom ?? await controller.getZoomLevel(),
      ),
    );
  }

  void zoomOutToFitAllMarkers(
      GoogleMapController controller, Set<Marker> markers,
      {Position? currentPosition}) {
    if (markers.isEmpty) return;

    double minLat;
    double maxLat;
    double minLng;
    double maxLng;

    // Start with the user position
    if (currentPosition != null) {
      minLat = currentPosition.latitude;
      maxLat = currentPosition.latitude;
      minLng = currentPosition.longitude;
      maxLng = currentPosition.longitude;
    } else {
      minLat = markers.first.position.latitude;
      maxLat = markers.first.position.latitude;
      minLng = markers.first.position.longitude;
      maxLng = markers.first.position.longitude;
    }

    // Iterate through all markers to find the bounding box
    for (Marker marker in markers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    // Create the bounds
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // Create camera update
    CameraUpdate cameraUpdate =
        CameraUpdate.newLatLngBounds(bounds, 50.0); // 50 is padding

    // Move camera to fit bounds
    controller.animateCamera(cameraUpdate);
    print("Zooming out to fit all markers");
  }

  void resetPosition(Completer<GoogleMapController> controller,
      Position currentPosition) async {
    await animateCameraToNewLatLng(controller,
        LatLng(currentPosition.latitude, currentPosition.longitude));
  }
}
