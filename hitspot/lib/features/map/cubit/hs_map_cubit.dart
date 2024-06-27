import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_state.dart';

class HSMapCubit extends Cubit<HSMapState> {
  HSMapCubit(this._initialCameraPosition) : super(const HSMapState()) {
    init();
  }

  final _databaseRepository = app.databaseRepository;
  final Position? _initialCameraPosition;
  final Completer<GoogleMapController> controller = Completer();

  Future<void> init() async {
    try {
      emit(state.copyWith(status: HSMapStatus.loading));
      late final LatLng cameraPosition;
      if (_initialCameraPosition != null) {
        cameraPosition = LatLng(
          _initialCameraPosition.latitude,
          _initialCameraPosition.longitude,
        );
      } else {
        cameraPosition =
            const LatLng(60.0, 60.0); // TODO: Change to place with most spots
      }
      emit(state.copyWith(
          cameraPosition: cameraPosition,
          currentPosition: _initialCameraPosition));
    } catch (e) {
      emit(state.copyWith(status: HSMapStatus.error));
      HSDebugLogger.logError("Error initializing map: $e");
    }
  }

  Future<void> fetchSpots() async {
    try {
      emit(state.copyWith(status: HSMapStatus.fetchingSpots));
      final LatLngBounds bounds = state.bounds!;
      final spots = await _databaseRepository.spotFetchSpotsInView(
        minLat: bounds.southwest.latitude,
        minLong: bounds.southwest.longitude,
        maxLat: bounds.northeast.latitude,
        maxLong: bounds.southwest.longitude,
      );
      HSDebugLogger.logSuccess("Fetched: ${spots.length} spots");
      emit(state.copyWith(spotsInView: spots, status: HSMapStatus.success));
    } catch (e) {
      emit(state.copyWith(status: HSMapStatus.error));
      HSDebugLogger.logError("Error fetching spots: $e");
    }
  }

  void onMapCreated(GoogleMapController cont) async {
    controller.complete(cont);
    controller.future.then((value) {
      value.setMapStyle(app.theme.mapStyle);
    });
  }

  void onCameraIdle() async {
    final bounds =
        await controller.future.then((value) => value.getVisibleRegion());
    emit(state.copyWith(status: HSMapStatus.fetchingSpots, bounds: bounds));
    HSDebugLogger.logInfo("bounds: $bounds");
    fetchSpots();
  }
}
