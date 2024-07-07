import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
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
        if (_distance(spot.latitude!, spot.longitude!, cluster.latitude,
                cluster.longitude) <=
            clusterRadius) {
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

    return clusters;
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
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

List<Cluster> clusterSpots(List<HSSpot> spots) {
  List<Cluster> clusters = [];
  double clusterRadius = 0.1; // Adjust this value to change cluster size

  for (var spot in spots) {
    bool addedToCluster = false;
    for (var cluster in clusters) {
      if (_distance(spot.latitude!, spot.longitude!, cluster.latitude,
              cluster.longitude) <=
          clusterRadius) {
        cluster.spots.add(spot);
        addedToCluster = true;
        break;
      }
    }
    if (!addedToCluster) {
      clusters.add(Cluster([spot]));
    }
  }

  return clusters;
}

double _distance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // in kilometers
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

class MapPainter extends CustomPainter {
  final List<Cluster> clusters;

  MapPainter({required this.clusters});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (var cluster in clusters) {
      final x = _longitudeToX(cluster.longitude, size.width);
      final y = _latitudeToY(cluster.latitude, size.height);
      final radius = 10 + (cluster.spots.length * 2).clamp(0, 20).toDouble();

      canvas.drawCircle(Offset(x, y), radius, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: cluster.spots.length.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  double _longitudeToX(double longitude, double width) {
    return (longitude + 180) * (width / 360);
  }

  double _latitudeToY(double latitude, double height) {
    return (90 - latitude) * (height / 180);
  }
}
