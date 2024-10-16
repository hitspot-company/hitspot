import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'dart:math' as math;

import 'package:pair/pair.dart';

part 'hs_map_wrapper_state.dart';

class HSMapWrapperCubit extends Cubit<HSMapWrapperState> {
  late final GoogleMapController mapController;
  late final void Function(HSSpot)? onMarkerTapped;
  late final void Function()? onCameraIdle;
  final _locationRepository = app.locationRepository;
  late final CameraPosition initialCameraPosition;
  final _databaseRepository = app.databaseRepository;

  HSMapWrapperCubit() : super(const HSMapWrapperState());

  // void init({
  //   void Function(HSSpot)? onMarkerTapped,
  //   void Function()? onCameraIdle,
  //   List<HSSpot> visibleSpots = const [],
  //   CameraPosition? initialCameraPosition,
  // }) {
  //   setOnMarkerTapped(onMarkerTapped);
  //   setOnCameraIdle(onCameraIdle);
  //   setVisibleSpots(visibleSpots);
  //   if (initialCameraPosition != null) {
  //     setInitialCameraPosition(initialCameraPosition);
  //   }
  // }

  void setVisibleSpots(List<HSSpot> spots) async {
    final currentSpots = state.visibleSpots;
    if (currentSpots == spots) return;
    // final freshCached =
    //     spots.where((e) => !state.cachedSpots.contains(e)).toList();
    emit(state.copyWith(visibleSpots: spots
        // cachedSpots: [...state.cachedSpots, ...freshCached]
        ));
  }

  void setInitialCameraPosition(CameraPosition initialCameraPosition) {
    this.initialCameraPosition = initialCameraPosition;
  }

  void setOnMarkerTapped(void Function(HSSpot)? onMarkerTapped) {
    if (onMarkerTapped == null) {
      HSDebugLogger.logError("onMarkerTapped is null");
      this.onMarkerTapped = (spot) {
        HSDebugLogger.logInfo("Using default onMarkerTapped");
        setSelectedSpot(spot);
      };
    } else {
      this.onMarkerTapped = onMarkerTapped;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    if (state.status == HSMapWrapperStatus.initial) {
      mapController = controller;
      emit(state.copyWith(status: HSMapWrapperStatus.initialised));
    }
  }

  void updateMarkers([List<HSSpot>? spots]) {
    if (spots == state.visibleSpots) return;
    spots ??= state.visibleSpots;
    final markers = spots.where((spot) {
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

  void setSelectedSpot(HSSpot? spot) {
    emit(state.copyWith(selectedSpot: spot));
  }

  void setOnCameraIdle(void Function()? onCameraIdle) {
    if (onCameraIdle == null) {
      HSDebugLogger.logError("onCameraIdle is null");
      this.onCameraIdle = () {
        HSDebugLogger.logInfo("Using default onCameraIdle");
        final position = state.cameraPosition;
        final markerLevel = HSSpotMarker.getMarkerLevel(position.zoom);
        if (markerLevel != state.markerLevel) {
          emit(state.copyWith(markerLevel: markerLevel));
          updateMarkers();
        }
      };
    } else {
      this.onCameraIdle = onCameraIdle;
    }
  }

  void onCameraMove(CameraPosition position) {
    emit(state.copyWith(cameraPosition: position));
  }

  Future<void> moveCamera(LatLng newPosition, double zoom) async {
    final newCameraPosition = CameraPosition(target: newPosition, zoom: zoom);
    await mapController
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    emit(state.copyWith(cameraPosition: newCameraPosition));
  }

  void clearMarkers() {
    emit(state.copyWith(markers: {}));
  }

  void _onMarkerTapped(HSSpot spot) {
    if (onMarkerTapped != null) {
      onMarkerTapped!(spot);
    } else {
      HSDebugLogger.logError("onMarkerTapped is not set");
    }
  }

  Future<void> zoomInToMarker([double zoom = 18.0]) async {
    try {
      if (state.selectedSpot.sid != null) {
        final spot = state.selectedSpot;
        await moveCamera(LatLng(spot.latitude!, spot.longitude!), zoom);
      }
    } catch (e) {
      HSDebugLogger.logError("Error zooming in to marker: $e");
    }
  }

  Future<void> zoomOut({bool force = false}) async {
    try {
      await _locationRepository.zoomToFitSpots(
          state.visibleSpots, mapController);
    } catch (e) {
      HSDebugLogger.logError("Error zooming out: $e");
    }
  }

  Future<Pair<CameraPosition, List<HSSpot>>?> getInitialCameraPositionAndSpots(
      Position currentPosition) async {
    try {
      final spots = await _databaseRepository.spotFetchClosest(
          lat: currentPosition.latitude, long: currentPosition.longitude);

      const padding = 0.1;
      final latlngs =
          spots.map((e) => LatLng(e.latitude!, e.longitude!)).toList();
      final bounds = _locationRepository.getLatLngBounds(latlngs);
      final center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );

      final latDelta = bounds.northeast.latitude - bounds.southwest.latitude;
      final lngDelta = bounds.northeast.longitude - bounds.southwest.longitude;

      final maxDelta = latDelta > lngDelta ? latDelta : lngDelta;
      final zoom = math.log(360 / (maxDelta + padding)) / math.ln2;

      final cameraPosition = CameraPosition(
        target: center,
        zoom: zoom,
      );
      return Pair(cameraPosition, spots);
    } catch (e) {
      HSDebugLogger.logError("Error getting initial camera position: $e");
      return null;
    }
  }

  @override
  Future<void> close() {
    if (state.status == HSMapWrapperStatus.initialised) {
      mapController.dispose();
    }
    HSDebugLogger.logInfo('HSMapWrapperCubit closed');
    return super.close();
  }

  @override
  String toString() => 'HSMapWrapperCubit';
}
