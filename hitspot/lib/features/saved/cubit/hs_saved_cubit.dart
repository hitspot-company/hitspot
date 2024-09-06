import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_saved_state.dart';

class HSSavedCubit extends Cubit<HSSavedState> {
  HSSavedCubit() : super(const HSSavedState()) {
    _init(useCache: true);
  }

  void updateStatus(HSSavedStatus status) =>
      emit(state.copyWith(status: status));

  Future<void> _init({bool useCache = false}) async {
    try {
      final List<HSBoard> ownBoards = await app.databaseRepository
          .boardFetchUserBoards(userID: currentUser.uid!, useCache: useCache);
      final List<HSBoard> savedBoards = await app.databaseRepository
          .boardFetchSavedBoards(userID: currentUser.uid!, useCache: useCache);
      final List<HSSpot> spots = await app.databaseRepository
          .spotFetchSaved(userID: currentUser.uid!, useCache: useCache);
      emit(state.copyWith(
          savedBoards: savedBoards, ownBoards: ownBoards, savedSpots: spots));
      updateStatus(HSSavedStatus.idle);
    } catch (e) {
      HSDebugLogger.logError("Error fetching boards: $e");
      updateStatus(HSSavedStatus.error);
    }
  }

  Future<void> refresh() async {
    await _init();
  }
}
