import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_saved_state.dart';

class HSSavedCubit extends Cubit<HSSavedState> {
  HSSavedCubit() : super(HSSavedState()) {
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
          savedBoards: savedBoards,
          ownBoards: ownBoards,
          savedSpots: spots,
          searchedBoardsResults: List.from(ownBoards),
          searchedSavedBoardsResults: List.from(savedBoards),
          searchedSavedSpotsResults: List.from(spots)));
      updateStatus(HSSavedStatus.idle);
    } catch (e) {
      HSDebugLogger.logError("Error fetching boards: $e");
      updateStatus(HSSavedStatus.error);
    }
  }

  Timer? _debounce;

  void updateQuery(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      emit(state.copyWith(query: val));
      _search();
    });
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
    await _init();
  }

  @override
  Future<void> close() {
    state.textEditingController.dispose();
    return super.close();
  }
}
