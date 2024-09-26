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
    final markers = state.visibleSpots.map((e) {
      final markerIcon = app.assets.getMarkerIcon(e, state.markerLevel);
      return Marker(
        markerId: MarkerId(e.sid!),
        position: LatLng(e.latitude!, e.longitude!),
        icon: markerIcon,
        onTap: () => _onMarkerTapped(e),
      );
    }).toSet();
    emit(state.copyWith(markers: markers));
  }

  void _onMarkerTapped(HSSpot spot) async {
    await _locationRepository.animateCameraToNewLatLng(
        mapController, LatLng(spot.latitude! - .0001, spot.longitude!), 18.0);
    emit(state.copyWith(selectedSpot: spot));
  }

  void resetSelectedSpot() {
    emit(state.copyWith(selectedSpot: const HSSpot()));
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
    final markerLevel = HSSpotMarker.getMarkerLevel(position.zoom);
    HSDebugLogger.logInfo("zoom: ${position.zoom}");
    if (markerLevel != state.markerLevel) {
      HSDebugLogger.logInfo("Marker Level Changed: $markerLevel");
      emit(state.copyWith(markerLevel: markerLevel));
      _placeMarkers();
    }
    emit(state.copyWith(cameraPosition: position));
  }
}
