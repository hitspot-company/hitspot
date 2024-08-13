import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_tags_explore_state.dart';

class HSTagsExploreCubit extends Cubit<HSTagsExploreState> {
  HSTagsExploreCubit(this.tag) : super(const HSTagsExploreState()) {
    initialize();
  }

  final String tag;

  void initialize() async {
    try {
      emit(state.copyWith(status: HSTagsExploreStatus.loadingTopSpot));
      final HSSpot topSpot =
          await app.databaseRepository.spotFetchTopSpotWithTag(tag);
      emit(state.copyWith(
          status: HSTagsExploreStatus.loadingSpots, topSpot: topSpot));
      final List<HSSpot> topSpots =
          await app.databaseRepository.tagFetchTopSpots(tag: tag);
      emit(state.copyWith(status: HSTagsExploreStatus.loaded, spots: topSpots));
    } catch (_) {
      HSDebugLogger.logError('Error fetching spots');
      emit(state.copyWith(status: HSTagsExploreStatus.error));
    }
  }
}
