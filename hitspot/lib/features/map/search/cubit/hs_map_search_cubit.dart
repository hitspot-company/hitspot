import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_search_state.dart';

class HSMapSearchCubit extends Cubit<HSMapSearchState> {
  HSMapSearchCubit() : super(const HSMapSearchState());

  Timer? _debounce;

  void updateQuery(String val) {
    emit(state.copyWith(query: val, status: HSMapSearchStatus.loading));
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(
        query: val,
      ));
      await fetchPredictions();
    });
  }

  Future<void> fetchPredictions() async {
    try {
      if (state.query.isEmpty) {
        emit(state.copyWith(
          predictions: [],
          status: HSMapSearchStatus.success,
        ));
        return;
      }
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () async {
        final predictions = await app.locationRepository
            .fetchPredictions(state.query, currentUser.uid!);
        emit(state.copyWith(
          predictions: predictions,
          status: HSMapSearchStatus.success,
        ));
      });
    } catch (e) {
      HSDebugLogger.logError("Failed to fetch predictions: $e");
      emit(state.copyWith(
        predictions: [],
        status: HSMapSearchStatus.failure,
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
