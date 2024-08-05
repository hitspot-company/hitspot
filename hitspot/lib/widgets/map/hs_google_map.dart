import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
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
    return BlocSelector<HSThemeBloc, HSThemeState, String>(
      selector: (state) => state.mapStyle ?? HSTheme.instance.mapStyleLight,
      builder: (context, mapStyle) {
        return GoogleMap(
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          fortyFiveDegreeImageryEnabled: fortyFiveDegreeImageryEnabled,
          style: mapStyle,
          initialCameraPosition: initialCameraPosition,
          onMapCreated: onMapCreated,
          myLocationButtonEnabled: false,
          myLocationEnabled: myLocationEnabled,
          markers: markers ?? {},
          onCameraIdle: onCameraIdle,
          onCameraMove: onCameraMove,
          onTap: onTap,
          onCameraMoveStarted: onCameraMoveStarted,
          cameraTargetBounds:
              cameraTargetBounds ?? CameraTargetBounds.unbounded,
        );
      },
    );
  }
}
