import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/view/cluster_map_page.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_cluster_map_state.dart';

class HsClusterMapCubit extends Cubit<HsClusterMapState> {
  HsClusterMapCubit() : super(const HsClusterMapState()) {
    _init();
  }

  static const DEFAULT_MARKER_PADDING = .0001;
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
    final spots = await _databaseRepository.spotFetchClosest(
      lat: _currentPosition.latitude,
      long: _currentPosition.longitude,
    );
    emit(state.copyWith(visibleSpots: spots));
    if (spots.isNotEmpty) {
      await _locationRepository.zoomToFitSpots(
          spots, await mapController.future);
    }
    emit(state.copyWith(status: HSClusterMapStatus.loaded));
  }

  void onCameraIdle() async {
    if (state.status == HSClusterMapStatus.nearby) return;
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
    final markers = state.visibleSpots.where((spot) {
      if (state.filters.isEmpty) return true;
      return spot.tags?.any((tag) => state.filters.contains(tag)) ?? false;
    }).map((e) {
      final markerIcon = app.assets.getMarkerIcon(e,
          level: state.markerLevel, isSelected: state.selectedSpot == e);
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
    _toggleSelectedSpot(spot);
    await _locationRepository.animateCameraToNewLatLng(mapController,
        LatLng(spot.latitude! - DEFAULT_MARKER_PADDING, spot.longitude!), 18.0);
  }

  void _toggleSelectedSpot([HSSpot? spot]) {
    emit(state.copyWith(status: HSClusterMapStatus.refreshing));
    emit(state.copyWith(selectedSpot: spot ?? const HSSpot()));
    _placeMarkers();
    emit(state.copyWith(status: HSClusterMapStatus.loaded));
  }

  void resetSelectedSpot() {
    _toggleSelectedSpot();
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
    if (markerLevel != state.markerLevel) {
      emit(state.copyWith(markerLevel: markerLevel));
      _placeMarkers();
    }
    emit(state.copyWith(cameraPosition: position));
  }

  List<String> fetchFilters() {
    final tags =
        state.visibleSpots.expand((spot) => spot.tags ?? []).toSet().toList();
    tags.sort();
    return tags.cast<String>();
  }

  Future<void> fetchSearch(BuildContext context) async {
    try {
      final HSPrediction? result = await showSearch(
        context: context,
        delegate: MapSearchDelegate(HSMapSearchCubit()),
      );
      if (result != null && result.placeID.isNotEmpty) {
        final HSPlaceDetails placeDetails = await _locationRepository
            .fetchPlaceDetails(placeID: result.placeID);
        _toggleSelectedSpot();
        await _locationRepository.animateCameraToNewLatLng(mapController,
            LatLng(placeDetails.latitude, placeDetails.longitude), 13.0);
      }
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
  }

  void showFilters(BuildContext context) async {
    List<String> filterOptions = fetchFilters();

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return HSFilterPopup(
            filterOptions: filterOptions, selected: state.filters);
      },
    );

    if (result != null) {
      emit(state.copyWith(status: HSClusterMapStatus.refreshing));
      emit(state.copyWith(filters: result));
      _placeMarkers();
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    }
  }

  void findNearby() async {
    try {
      _toggleSelectedSpot();
      emit(state.copyWith(status: HSClusterMapStatus.nearby));
      final latlng = state.cameraPosition.target;
      final nearbySpots = await _databaseRepository.spotFetchClosest(
          lat: latlng.latitude, long: latlng.longitude);
      if (nearbySpots.isNotEmpty) {
        emit(state.copyWith(visibleSpots: nearbySpots));
        await _locationRepository.zoomToFitSpots(
            nearbySpots, await mapController.future);
        _placeMarkers();
      }
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    } catch (e) {
      HSDebugLogger.logError("Failed to get nearby spots: $e");
    }
  }

  Future<void> animateToCurrentLocation() async {
    try {
      final currentPosition = await _getPosition();
      _locationRepository.resetPosition(mapController, currentPosition);
    } catch (e) {
      HSDebugLogger.logError("Failed to animate to current location: $e");
    }
  }
}
