import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class MapPage extends StatefulWidget {
  final List<HSSpot> spots;
  const MapPage({Key? key, required this.spots}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  double currentZoom = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Clustered Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.spots[0].latitude!, widget.spots[0].longitude!),
          zoom: currentZoom,
        ),
        markers: markers,
        onCameraMove: (CameraPosition position) {
          currentZoom = position.zoom;
        },
        onCameraIdle: () {
          _updateClusters();
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateClusters();
  }

  void _updateClusters() {
    double clusterRadius =
        100 / currentZoom; // Adjust this value to change clustering behavior
    List<Cluster> clusters = _clusterSpots(widget.spots, clusterRadius);

    setState(() {
      markers.clear();
      for (var cluster in clusters) {
        markers.add(
          Marker(
            markerId: MarkerId(
                cluster.latitude.toString() + cluster.longitude.toString()),
            position: LatLng(cluster.latitude, cluster.longitude),
            infoWindow: InfoWindow(title: '${cluster.spots.length} spots'),
            icon: BitmapDescriptor.defaultMarkerWithHue(cluster.spots.length > 1
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueRed),
          ),
        );
      }
    });
  }

  List<Cluster> _clusterSpots(List<HSSpot> spots, double clusterRadius) {
    List<Cluster> clusters = [];

    for (var spot in spots) {
      bool addedToCluster = false;
      for (var cluster in clusters) {
        final dis = app.locationRepository.distanceBetween(
            spot1: spot, lat2: cluster.latitude, long2: cluster.longitude);
        HSDebugLogger.logInfo("""
Cluster location: (${cluster.latitude}, ${cluster.longitude})
Spot location: (${spot.latitude}, ${spot.longitude})
Distance: $dis
Cluster Radius: $clusterRadius
""");
        if (dis <= clusterRadius) {
          cluster.spots.add(spot);
          cluster._calculateCenter();
          addedToCluster = true;
          break;
        }
      }
      if (!addedToCluster) {
        clusters.add(Cluster([spot]));
      }
    }

    for (var cluster in clusters) {
      HSDebugLogger.logInfo(
          "Cluster at (${cluster.latitude}, ${cluster.longitude}) with ${cluster.spots.length} spots");
    }

    return clusters;
  }
}

class Cluster {
  final List<HSSpot> spots;
  late double latitude;
  late double longitude;

  Cluster(this.spots) {
    _calculateCenter();
  }

  void _calculateCenter() {
    double sumLat = 0;
    double sumLon = 0;
    for (var spot in spots) {
      sumLat += spot.latitude!;
      sumLon += spot.longitude!;
    }
    latitude = sumLat / spots.length;
    longitude = sumLon / spots.length;
  }
}
