import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_single_spot_state.dart';

class HSSingleSpotCubit extends Cubit<HsSingleSpotState> {
  HSSingleSpotCubit(this.spotID) : super(const HsSingleSpotState()) {
    _fetchSpot();
  }

  final String spotID;
  final _databaseRepository = app.databaseRepository;

  Future<void> _fetchSpot() async {
    try {
      final HSSpot spot =
          await _databaseRepository.spotfetchSpotWithAuthor(spotID: spotID);
      HSDebugLogger.logSuccess("Fetched spot: $spot");
      HSDebugLogger.logSuccess("With images: ${spot.images.toString()}");
      emit(state.copyWith(spot: spot));
      emit(state.copyWith(status: HSSingleSpotStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError("Error fetching spot: $_");
      emit(state.copyWith(status: HSSingleSpotStatus.error));
    }
  }
}
