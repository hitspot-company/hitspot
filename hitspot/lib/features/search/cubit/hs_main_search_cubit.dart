import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/main.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_main_search_state.dart';

class HSMainSearchCubit extends Cubit<HSMainSearchState> {
  HSMainSearchCubit() : super(const HSMainSearchState());

  Timer? _debounce;

  void updateQuery(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(query: val, users: await fetchPredictions()));
    });
  }

  Future<List<HSSpot>> fetchSpots() async {
    try {
      final query = state.query;
      final List<Map<String, dynamic>> fetchedSpots = await supabase
          .from('spots')
          .select()
          .textSearch('title', "$query:*")
          .limit(20);
      final List<HSSpot> spotsWithImages = [];
      for (var i = 0; i < fetchedSpots.length; i++) {
        final HSSpot spot = HSSpot.deserialize(fetchedSpots[i]);
        spotsWithImages.add(
            await app.databaseRepository.spotfetchSpotWithAuthor(spot: spot));
      }
      emit(state.copyWith(spots: spotsWithImages));
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      return [];
    }
    return (state.spots);
  }

  Future<List<HSTag>> fetchTags() async {
    try {
      final query = state.query;
      final List<HSTag> fetchedTags =
          await app.databaseRepository.tagSearch(query: query);
      emit(state.copyWith(tags: fetchedTags));
      return state.tags;
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      return [];
    }
  }

  Future<List<HSBoard>> fetchBoards() async {
    try {
      final query = state.query;
      final List<Map<String, dynamic>> fetchedBoards = await supabase
          .from('boards')
          .select()
          .textSearch('title', "$query:*")
          .limit(20);
      emit(state.copyWith(
          boards: fetchedBoards.map(HSBoard.deserialize).toList()));
      return (state.boards);
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      return [];
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final query = state.query;
      final List<Map<String, dynamic>> fetchedUsers = await supabase
          .from('users')
          .select()
          .textSearch('fts', "$query:*")
          .limit(20);
      emit(
          state.copyWith(users: fetchedUsers.map(HSUser.deserialize).toList()));
    } catch (e) {
      emit(state.copyWith(users: []));
      HSDebugLogger.logError("Error $e");
    }
  }

  Future<List<HSUser>> fetchPredictions() async {
    if (state.query.isNotEmpty) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () async {
        await _fetchUsers();
      });
    }
    return (state.users);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
