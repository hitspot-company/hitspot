import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class HSGoogleMap extends StatelessWidget {
  const HSGoogleMap({
    super.key,
    this.initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 16.0,
    ),
    this.markers,
    this.onMapCreated,
    this.onCameraIdle,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onTap,
    this.fortyFiveDegreeImageryEnabled = false,
    this.myLocationEnabled = true,
    this.cameraTargetBounds,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker>? markers;
  final Function(GoogleMapController)? onMapCreated;
  final Function()? onCameraIdle, onCameraMoveStarted;
  final Function(CameraPosition)? onCameraMove;
  final Function(LatLng)? onTap;
  final bool fortyFiveDegreeImageryEnabled, myLocationEnabled;
  final CameraTargetBounds? cameraTargetBounds;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      fortyFiveDegreeImageryEnabled: fortyFiveDegreeImageryEnabled,
      style: app.theme.mapStyleDark,
      initialCameraPosition: initialCameraPosition,
      onMapCreated: onMapCreated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      markers: markers ?? {},
      onCameraIdle: onCameraIdle,
      onCameraMove: onCameraMove,
      onTap: onTap,
      onCameraMoveStarted: onCameraMoveStarted,
      cameraTargetBounds: cameraTargetBounds ?? CameraTargetBounds.unbounded,
    );
  }
}
