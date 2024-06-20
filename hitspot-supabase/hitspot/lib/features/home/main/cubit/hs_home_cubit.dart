import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_home_state.dart';

class HSHomeCubit extends Cubit<HSHomeState> {
  HSHomeCubit() : super(const HSHomeState()) {
    _fetchInitial();
  }

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
      emit(state.copyWith(nearbySpots: ret));
    } catch (_) {
      HSDebugLogger.logError("Error fetching nearby spots: $_");
    }
  }
}
