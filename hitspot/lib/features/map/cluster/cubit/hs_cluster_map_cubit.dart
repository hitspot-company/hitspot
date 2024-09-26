import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_cluster_map_state.dart';

class HsClusterMapCubit extends Cubit<HsClusterMapState> {
  HsClusterMapCubit() : super(const HsClusterMapState()) {
    _init();
  }

  final _databaseRepository = app.databaseRepository;
  final _locationRepository = app.locationRepository;
  late final Position _currentPosition;
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  CameraPosition get initialCameraPosition => CameraPosition(
        target: LatLng(
          _currentPosition.latitude,
          _currentPosition.longitude,
        ),
        zoom: 15,
      );

  void _init() async {
    emit(state.copyWith(status: HSClusterMapStatus.loading));
    _currentPosition = await _getPosition();
    // _markerIcon = await _getMarkerIcon();
    final spots = await _databaseRepository.spotFetchClosest(
      lat: _currentPosition.latitude,
      long: _currentPosition.longitude,
    );
    emit(state.copyWith(
      status: HSClusterMapStatus.loaded,
      visibleSpots: spots,
    ));
  }

  // Future<BitmapDescriptor> _getMarkerIcon() async {
  //   final asset = await rootBundle.load('assets/map/truck.png');
  //   final icon = BitmapDescriptor.fromBytes(asset.buffer.asUint8List());
  //   return icon;
  // }

  // Future<BitmapDescriptor> _getMarkerIcon() async {
  //   final BitmapDescriptor customIcon = await BitmapDescriptor.asset(
  //     const ImageConfiguration(size: Size(100, 100)),
  //     'assets/map/truck.png',
  //   );
  //   return customIcon;
  // }

  void onCameraIdle() async {
    HSDebugLogger.logInfo("Camera Idle");
    emit(state.copyWith(status: HSClusterMapStatus.refreshing));
    final controller = await mapController.future;
    final center = await controller.getVisibleRegion();
    final spots = await _databaseRepository.spotFetchInBounds(
      minLat: center.southwest.latitude,
      minLong: center.southwest.longitude,
      maxLat: center.northeast.latitude,
      maxLong: center.northeast.longitude,
    );
    emit(state.copyWith(visibleSpots: spots));
    _placeMarkers();
    emit(state.copyWith(status: HSClusterMapStatus.loaded));
  }

  void _placeMarkers() {
    // final markers = state.visibleSpots
    //     .map((e) => Marker(
    //           markerId: MarkerId(e.sid!),
    //           position: LatLng(e.latitude!, e.longitude!),
    //           icon: app.assets.getSpotMarker(e),
    //           infoWindow: InfoWindow(
    //             title: e.title!,
    //             snippet: e.address,
    //           ),
    //         ))
    //     .toSet();
    // emit(state.copyWith(markers: markers));
  }

  Future<Position> _getPosition() async {
    try {
      return app.currentPosition ??
          await _locationRepository.getCurrentLocation();
    } catch (e) {
      return (kDefaultPosition);
    }
  }

  void onCameraMoved(CameraPosition position) {
    emit(state.copyWith(cameraPosition: position));
  }

  // void _resizeMarkers() {
  //   final zoom = state.cameraPosition.zoom;
  //   final size = calculateMarkerSize(zoom);
  //   final newMarkers = state.markers
  //       .map((e) => e.copyWith(
  //             icon: e.icon!.copyWith(
  //               size: Size(size, size),
  //             ),
  //           ))
  //       .toSet();
  //   emit(state.copyWith(markers: newMarkers));
  // }
}
