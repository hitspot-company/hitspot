import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_saved_state.dart';

class HSSavedCubit extends Cubit<HSSavedState> {
  final int batchSize = 10;

  HSSavedCubit() : super(const HSSavedState()) {
    init();
  }

  final TextEditingController controller = TextEditingController();
  Timer? _debounce;

  void updateStatus(HSSavedStatus status) =>
      emit(state.copyWith(status: status));

  void init() async {
    try {
      emit(state.copyWith(status: HSSavedStatus.loading));
      savedBoardsPage =
          HSBoardsPage(pageSize: batchSize, fetch: _fetchSavedBoards);
      yourBoardsPage =
          HSBoardsPage(pageSize: batchSize, fetch: _fetchYourBoards);
      savedSpotsPage =
          HSSpotsPage(pageSize: batchSize, fetch: _fetchSavedSpots);
    } catch (e) {
      HSDebugLogger.logError("Error fetching saved: $e");
      emit(state.copyWith(status: HSSavedStatus.error));
    }
  }

  late final HSBoardsPage yourBoardsPage;
  late final HSBoardsPage savedBoardsPage;
  late final HSSpotsPage savedSpotsPage;

  Future<List<HSBoard>> _fetchSavedBoards(
      int batchSize, int batchOffset) async {
    try {
      final List<HSBoard> savedBoards = await app.databaseRepository
          .boardFetchSavedBoards(
              userID: currentUser.uid!,
              batchSize: batchSize,
              batchOffset: batchOffset,
              useCache: batchOffset == 0);
      return savedBoards;
    } catch (e) {
      HSDebugLogger.logError("Error fetching saved boards: $e");
      return [];
    }
  }

  Future<List<HSBoard>> _fetchYourBoards(int batchSize, int batchOffset) async {
    try {
      final List<HSBoard> yourBoards = await app.databaseRepository
          .boardFetchUserBoards(
              userID: currentUser.uid!,
              batchSize: batchSize,
              batchOffset: batchOffset,
              useCache: batchOffset == 0);
      return yourBoards;
    } catch (e) {
      HSDebugLogger.logError("Error fetching saved boards: $e");
      return [];
    }
  }

  Future<List<HSSpot>> _fetchSavedSpots(int batchSize, int batchOffset) async {
    try {
      final List<HSSpot> savedSpots = await app.databaseRepository
          .spotFetchSaved(
              userID: currentUser.uid!,
              batchSize: batchSize,
              batchOffset: batchOffset,
              useCache: batchOffset == 0);
      return savedSpots;
    } catch (e) {
      HSDebugLogger.logError("Error fetching saved boards: $e");
      return [];
    }
  }

  void updateQuery(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      HSDebugLogger.logInfo("Searching for $val");
      emit(state.copyWith(query: val));
      _search();
    });
  }

  void addSavedBoardToCache(HSBoard board) {
    if (!state.savedBoards.contains(board)) {
      emit(state.copyWith(savedBoards: [board, ...state.savedBoards]));
    }
  }

  void addOwnBoardToCache(HSBoard board) {
    if (!state.ownBoards.contains(board)) {
      emit(state.copyWith(ownBoards: [board, ...state.ownBoards]));
    }
  }

  void addSavedSpotToCache(HSSpot spot) {
    if (!state.savedSpots.contains(spot)) {
      emit(state.copyWith(savedSpots: [spot, ...state.savedSpots]));
    }
  }

  void _search() {
    final query = state.query;

    final List<HSBoard> yourBoardsResults = _searchInYourBoards(query);
    final List<HSBoard> savedBoardsResults = _searchInSavedBoards(query);
    final List<HSSpot> savedSpotsResults = _searchInSavedSpots(query);

    emit(state.copyWith(
      searchedBoardsResults: yourBoardsResults,
      searchedSavedBoardsResults: savedBoardsResults,
      searchedSavedSpotsResults: savedSpotsResults,
    ));
  }

  List<HSBoard> _searchInYourBoards(String query) {
    return state.ownBoards.where((item) => _filter(item, query)).toList();
  }

  List<HSBoard> _searchInSavedBoards(String query) {
    return state.savedBoards.where((item) => _filter(item, query)).toList();
  }

  List<HSSpot> _searchInSavedSpots(String query) {
    return state.savedSpots.where((item) => _filter(item, query)).toList();
  }

  bool _filter(dynamic item, String query) {
    if (query == "") {
      return true;
    }

    if (item.title?.toLowerCase().contains(query.toLowerCase()) ?? false) {
      return true;
    }

    if (item.description?.toLowerCase().contains(query.toLowerCase()) ??
        false) {
      return true;
    }

    if (item is HSBoard) {
      if (item.collaborators?.any((element) =>
              element.name?.toLowerCase().contains(query.toLowerCase()) ??
              false) ??
          false) {
        return true;
      }
    }

    if (item is HSSpot) {
      if (item.author?.name?.toLowerCase().contains(query.toLowerCase()) ??
          false) {
        return true;
      }

      if (item.tags?.any((element) =>
              element.toLowerCase().contains(query.toLowerCase())) ??
          false) {
        return true;
      }
    }

    return false;
  }

  Future<void> refresh() async {
    emit(
      state.copyWith(
        savedBoards: [],
        ownBoards: [],
        savedSpots: [],
        batchOffset: 0,
      ),
    );
  }

  @override
  Future<void> close() {
    controller.dispose();
    yourBoardsPage.dispose();
    savedBoardsPage.dispose();
    savedSpotsPage.dispose();
    return super.close();
  }
}
