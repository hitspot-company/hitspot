import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_single_spot_state.dart';

class HSSingleSpotCubit extends Cubit<HsSingleSpotState> {
  HSSingleSpotCubit(this.spotID) : super(const HsSingleSpotState()) {
    _fetchSpot();
  }

  final String spotID;
  final _databaseRepository = app.databaseRepository;
  LatLng? get spotLocation =>
      state.spot.latitude == null || state.spot.longitude == null
          ? null
          : LatLng(state.spot.latitude!, state.spot.longitude!);

  Future<void> _fetchSpot() async {
    try {
      final HSSpot spot =
          await _databaseRepository.spotfetchSpotWithAuthor(spotID: spotID);
      final bool isSpotLiked = await _databaseRepository.spotIsSpotLiked(
          spotID: spotID, userID: currentUser.uid);
      final bool isSpotSaved = await _databaseRepository.spotIsSaved(
          spotID: spotID, userID: currentUser.uid);
      HSDebugLogger.logSuccess("Fetched spot: $spot");
      HSDebugLogger.logSuccess("With images: ${spot.images.toString()}");
      emit(state.copyWith(
          spot: spot, isSpotLiked: isSpotLiked, isSpotSaved: isSpotSaved));
      emit(state.copyWith(status: HSSingleSpotStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError("Error fetching spot: $_");
      emit(state.copyWith(status: HSSingleSpotStatus.error));
    }
  }

  Future<void> likeDislikeSpot() async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.liking));
      await Future.delayed(const Duration(seconds: 1));
      final bool isSpotLiked = await _databaseRepository.spotLikeDislike(
          spotID: spotID, userID: currentUser.uid);
      emit(state.copyWith(
          isSpotLiked: isSpotLiked, status: HSSingleSpotStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> saveUnsaveSpot() async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.saving));
      await Future.delayed(const Duration(seconds: 1));
      final bool isSpotSaved = await _databaseRepository.spotSaveUnsave(
          spotID: spotID, userID: currentUser.uid);
      emit(state.copyWith(
          isSpotSaved: isSpotSaved, status: HSSingleSpotStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }
}
