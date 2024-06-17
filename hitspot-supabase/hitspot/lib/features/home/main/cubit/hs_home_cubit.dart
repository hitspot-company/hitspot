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
      emit(state.copyWith(
          status: HSHomeStatus.idle, tredingBoards: tredingBoards));
    } catch (_) {
      HSDebugLogger.logError("Error fetching initial data: $_");
    }
  }
}
