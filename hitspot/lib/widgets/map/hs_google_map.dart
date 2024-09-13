import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class HSGoogleMap extends StatelessWidget {
  const HSGoogleMap({
    super.key,
    this.initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 16.0,
    ),
    this.myLocationButtonEnabled = false,
    this.myLocationButtonPosition,
    this.markers,
    this.onMapCreated,
    this.onCameraIdle,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onTap,
    this.fortyFiveDegreeImageryEnabled = false,
    this.myLocationEnabled = true,
    this.cameraTargetBounds,
    this.myLocationButtonCallback,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker>? markers;
  final Function(GoogleMapController)? onMapCreated;
  final Function()? onCameraIdle, onCameraMoveStarted;
  final Function(CameraPosition)? onCameraMove;
  final Function(LatLng)? onTap;
  final bool fortyFiveDegreeImageryEnabled,
      myLocationEnabled,
      myLocationButtonEnabled;
  final CameraTargetBounds? cameraTargetBounds;
  final Alignment? myLocationButtonPosition;
  final VoidCallback? myLocationButtonCallback;

  @override
  Widget build(BuildContext context) {
    if (myLocationButtonEnabled) {
      assert(myLocationButtonCallback != null,
          "Provide the `myLocationButtonCallback` when using myLocationButton");
    }
    return BlocSelector<HSThemeBloc, HSThemeState, String>(
      selector: (state) => state.mapStyle ?? HSTheme.instance.mapStyleLight,
      builder: (context, mapStyle) {
        return Stack(
          fit: StackFit.expand,
          children: [
            GoogleMap(
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
            ),
            if (myLocationButtonEnabled)
              Positioned(
                bottom: 180,
                left: 0,
                right: 0,
                child: Align(
                  alignment: myLocationButtonPosition ?? Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      backgroundColor: currentTheme.scaffoldBackgroundColor,
                      foregroundColor: Colors.white,
                      onPressed: myLocationButtonCallback,
                      child: const Icon(Icons.my_location_outlined),
                    ),
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
