import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_wrapper_state.dart';

class HSMapWrapperCubit extends Cubit<HSMapWrapperState> {
  late final GoogleMapController mapController;
  late final void Function(HSSpot)? onMarkerTapped;

  HSMapWrapperCubit() : super(const HSMapWrapperState());

  void setOnMarkerTapped(void Function(HSSpot)? onMarkerTapped) {
    this.onMarkerTapped = onMarkerTapped;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateMarkers(List<HSSpot> spots) {
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

  void onCameraMove(CameraPosition cameraPosition) {
    emit(state.copyWith(cameraPosition: cameraPosition));
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

  @override
  Future<void> close() {
    mapController.dispose();
    return super.close();
  }

  @override
  String toString() => 'HSMapWrapperCubit';
}
