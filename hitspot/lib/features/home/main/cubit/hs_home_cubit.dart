import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/main.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_home_state.dart';

class HSHomeCubit extends Cubit<HSHomeState> {
  HSHomeCubit() : super(const HSHomeState()) {
    _fetchInitial();
  }

  late final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Completer<GoogleMapController> get mapController => _mapController;

  Future<void> _fetchInitial() async {
    try {
      emit(state.copyWith(status: HSHomeStatus.loading));
      final List<HSBoard> tredingBoards =
          await app.databaseRepository.boardFetchTrendingBoards();
      final permission =
          await app.locationRepository.requestLocationPermission();
      if (permission) {
        await _fetchNearbySpots();
      }
      emit(state.copyWith(
          status: HSHomeStatus.idle, tredingBoards: tredingBoards));
    } catch (_) {
      HSDebugLogger.logError("Error fetching initial data: $_");
    }
  }

  Future<void> handleRefresh() async {
    state.copyWith(status: HSHomeStatus.loading);
    await Future.delayed(const Duration(seconds: 2));
    state.copyWith(nearbySpots: [], tredingBoards: []);
    await _fetchInitial();
  }

  Future<void> _fetchNearbySpots() async {
    try {
      final currentPosition = await app.locationRepository.getCurrentLocation();
      final lat = currentPosition.latitude;
      final long = currentPosition.longitude;
      final List<HSSpot> nearbySpots = await app.databaseRepository
          .spotFetchSpotsWithinRadius(lat: lat, long: long);
      final List<HSSpot> ret = [];
      for (var i = 0; i < nearbySpots.length; i++) {
        ret.add(
          nearbySpots[i].copyWith(
            author: await app.databaseRepository
                .userRead(userID: nearbySpots[i].createdBy),
          ),
        );
      }
      emit(state.copyWith(nearbySpots: ret, currentPosition: currentPosition));
    } catch (_) {
      HSDebugLogger.logError("Error fetching nearby spots: $_");
    }
  }

  Future<void> animateCameraToNewLatLng(LatLng location) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }
}
