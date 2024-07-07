import 'dart:async';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart'
// as gmcm;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hs_location_repository/src/models/hs_place_details.dart';
import 'package:hs_location_repository/src/models/hs_prediction.dart';
// import 'package:hs_location_repository/src/models/hs_spot_with_cluster_item.dart'
// as gm;
import 'package:map_launcher/map_launcher.dart' as ml;
import 'package:uuid/uuid.dart';

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

  /// Map Spots Clustering
  // gmcm.ClusterManager<gm.HSSpotWithClusterItem> initializeClusterManager(
  //     List<HSSpot> spots, Function(Set<Marker>) _updateMarkers) {
  //   return gmcm.ClusterManager<gm.HSSpotWithClusterItem>(
  //       spots.map((e) => gm.HSSpotWithClusterItem(e)).toList(),
  //       _updateMarkers, // Method to be called when markers are updated
  //       // markerBuilder:
  //       // _markerBuilder, // Optional : Method to implement if you want to customize markers
  //       levels: [
  //         1,
  //         4.25,
  //         6.75,
  //         8.25,
  //         11.5,
  //         14.5,
  //         16.0,
  //         16.5,
  //         20.0
  //       ], // Optional : Configure this if you want to change zoom levels at which the clustering precision change
  //       extraPercent:
  //           0.2, // Optional : This number represents the percentage (0.2 for 20%) of latitude and longitude (in each direction) to be considered on top of the visible map bounds to render clusters. This way, clusters don't "pop out" when you cross the map.
  //       stopClusteringZoom:
  //           17.0 // Optional : The zoom level to stop clustering, so it's only rendering single item "clusters"
  //       );
  // }

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
}
