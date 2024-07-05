import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_tags_explore_state.dart';

class HsTagsExploreCubit extends Cubit<HsTagsExploreState> {
  HsTagsExploreCubit(this.tag) : super(const HsTagsExploreState()) {
    initialize();
  }

  final String tag;

  void initialize() async {
    HSDebugLogger.logInfo('HsTagsExploreCubit: initialize');
    emit(state.copyWith(status: HSTagsExploreStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    final HSSpot topSpot =
        await app.databaseRepository.spotFetchTopSpotWithTag(tag);
    HSDebugLogger.logSuccess("Fetched top spot: $topSpot");
    emit(state.copyWith(status: HSTagsExploreStatus.loaded, topSpot: topSpot));
  }
}
