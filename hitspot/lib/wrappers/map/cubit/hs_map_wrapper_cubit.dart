import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_wrapper_state.dart';

class HSMapWrapperCubit extends Cubit<HSMapWrapperState> {
  late final GoogleMapController mapController;
  late final void Function(HSSpot)? onMarkerTapped;
  final _locationRepository = app.locationRepository;

  HSMapWrapperCubit() : super(const HSMapWrapperState());

  void setVisibleSpots(List<HSSpot> spots) async {
    final currentSpots = state.visibleSpots;
    if (currentSpots == spots) return;
    // final freshCached =
    //     spots.where((e) => !state.cachedSpots.contains(e)).toList();
    emit(state.copyWith(
      visibleSpots: spots,
      // cachedSpots: [...state.cachedSpots, ...freshCached]
    ));
  }

  void setOnMarkerTapped(void Function(HSSpot)? onMarkerTapped) {
    this.onMarkerTapped = onMarkerTapped;
  }

  void onMapCreated(GoogleMapController controller) {
    if (state.status == HSMapWrapperStatus.initial) {
      mapController = controller;
      emit(state.copyWith(status: HSMapWrapperStatus.initialised));
    }
  }

  void updateMarkers([List<HSSpot>? spots]) {
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

  void setSelectedSpot(HSSpot spot) {
    emit(state.copyWith(selectedSpot: spot));
  }

  void onCameraIdle() {
    final position = state.cameraPosition;
    final markerLevel = HSSpotMarker.getMarkerLevel(position.zoom);
    if (markerLevel != state.markerLevel) {
      emit(state.copyWith(markerLevel: markerLevel));
      updateMarkers();
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

  @override
  Future<void> close() {
    mapController.dispose();
    return super.close();
  }

  @override
  String toString() => 'HSMapWrapperCubit';
}
