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
  late final HSSpotsPage spotsPage;

  void initialize() async {
    try {
      emit(state.copyWith(status: HSTagsExploreStatus.loadingTopSpot));
      final HSSpot topSpot =
          await app.databaseRepository.spotFetchTopSpotWithTag(tag);
      spotsPage = HSSpotsPage(fetch: _fetch);
      emit(
          state.copyWith(status: HSTagsExploreStatus.loaded, topSpot: topSpot));
    } catch (e) {
      HSDebugLogger.logError('Error fetching spot ${e.toString()}');
      emit(state.copyWith(status: HSTagsExploreStatus.error));
    }
  }

  Future<List<HSSpot>> _fetch(int batchSize, int batchOffset) async {
    try {
      final List<HSSpot> spots = await app.databaseRepository.tagFetchTopSpots(
          tag: tag, batchSize: batchSize, batchOffset: batchOffset);
      return spots;
    } catch (e) {
      HSDebugLogger.logError('Error fetching spot ${e.toString()}');
      emit(state.copyWith(status: HSTagsExploreStatus.error));
      return [];
    }
  }
}
