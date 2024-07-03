import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_search_state.dart';

class HSMapSearchCubit extends Cubit<HSMapSearchState> {
  HSMapSearchCubit() : super(const HSMapSearchState());

  void updateQuery(String val) => emit(state.copyWith(query: val));

  Future<List<HSPrediction>> fetchPredictions() async {
    try {
      if (state.query.isEmpty) return [];
      final predictions = await app.locationRepository
          .fetchPredictions(state.query, currentUser.uid!);
      emit(state.copyWith(predictions: predictions));
      return state.predictions;
    } catch (e) {
      HSDebugLogger.logError("Failed to fetch predictions: $e");
      return [];
    }
  }
}
