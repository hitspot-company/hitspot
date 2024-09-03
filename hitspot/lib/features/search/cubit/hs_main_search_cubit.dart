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
  HSMainSearchCubit() : super(const HSMainSearchState()) {
    _init();
  }

  Timer? _debounce;
  final _databaseRepository = app.databaseRepository;
  bool get isLoading => state.status == HSMainSearchStatus.loading;

  void _init() async {
    toggleLoading(true);

    _fetchTrendingSpots();
    _fetchTrendingBoards();
    _fetchTrendingUsers();
    _fetchTrendingTags();

    toggleLoading(false);
  }

  void updateQuery(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(query: val));
      if (val.isNotEmpty) {
        fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    toggleLoading(true);
    _fetchUsers();
    _fetchSpots();
    _fetchTags();
    _fetchBoards();
    toggleLoading(false);
  }

  void toggleLoading([bool value = false]) => emit(state.copyWith(
      status: value ? HSMainSearchStatus.loading : HSMainSearchStatus.loaded));

  Future<void> _fetchTrendingSpots() async {
    try {
      final List<HSSpot> fetchedSpots =
          await _databaseRepository.spotFetchTrendingSpots();
      emit(state.copyWith(trendingSpots: fetchedSpots));
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      emit(state.copyWith(status: HSMainSearchStatus.error));
    }
  }

  Future<void> waitDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _fetchSpots() async {
    try {
      final query = state.query;
      final List<Map<String, dynamic>> fetchedSpots = await supabase
          .from('spots')
          .select()
          .textSearch('fts', "$query:*")
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
      emit(state.copyWith(status: HSMainSearchStatus.error));
    }
  }

  Future<void> _fetchTags() async {
    try {
      final query = state.query;

      final List<HSTag> fetchedTags =
          await app.databaseRepository.tagSearch(query: query);
      emit(state.copyWith(tags: fetchedTags));
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      emit(state.copyWith(status: HSMainSearchStatus.error));
    }
  }

  Future<void> _fetchTrendingTags() async {
    try {
      toggleLoading(true);
      final List<Map<String, dynamic>> fetchedTags = await supabase
          .from('tags')
          .select()
          .order('spots_count', ascending: false)
          .limit(20);
      emit(state.copyWith(
          trendingTags: fetchedTags.map(HSTag.deserialize).toList()));
      toggleLoading();
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      emit(state.copyWith(status: HSMainSearchStatus.error));
    }
  }

  Future<void> _fetchBoards() async {
    try {
      toggleLoading(true);

      final query = state.query;
      final List<Map<String, dynamic>> fetchedBoards = await supabase
          .from('boards')
          .select()
          .textSearch('fts', "$query:*")
          .limit(20);
      emit(state.copyWith(
          boards: fetchedBoards.map(HSBoard.deserialize).toList()));
      toggleLoading();
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      emit(state.copyWith(status: HSMainSearchStatus.error));
    }
  }

  Future<void> _fetchTrendingBoards() async {
    try {
      final fetchedBoards =
          await _databaseRepository.boardFetchTrendingBoards();
      emit(state.copyWith(trendingBoards: fetchedBoards));
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      emit(state.copyWith(status: HSMainSearchStatus.error));
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
      HSDebugLogger.logError("Error $e");
      emit(state.copyWith(status: HSMainSearchStatus.error));
    }
  }

  Future<void> _fetchTrendingUsers() async {
    try {
      final List<Map<String, dynamic>> fetchedUsers = await supabase
          .from('users')
          .select()
          .eq("is_profile_completed", true)
          .order('followers_count', ascending: false)
          .limit(20)
          .select();
      emit(state.copyWith(
          trendingUsers: fetchedUsers.map(HSUser.deserialize).toList()));
    } catch (e) {
      HSDebugLogger.logError("Error $e");
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

enum HSMainSearchCubitSearchType {
  spots,
  tags,
  boards,
  users,
}
