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

  HSSavedCubit() : super(HSSavedState()) {
    _fetch();
  }

  void updateStatus(HSSavedStatus status) =>
      emit(state.copyWith(status: status));

  Future<void> _fetch() async {
    try {
      final List<HSBoard> ownBoards = await app.databaseRepository
          .boardFetchUserBoards(
              userID: currentUser.uid!,
              batchSize: batchSize,
              batchOffset: state.batchOffset * batchSize,
              useCache: state.batchOffset == 0);
      final List<HSBoard> savedBoards = await app.databaseRepository
          .boardFetchSavedBoards(
              userID: currentUser.uid!,
              batchSize: batchSize,
              batchOffset: state.batchOffset * batchSize,
              useCache: state.batchOffset == 0);
      final List<HSSpot> spots = await app.databaseRepository.spotFetchSaved(
          userID: currentUser.uid!,
          batchSize: batchSize,
          batchOffset: state.batchOffset * batchSize,
          useCache: state.batchOffset == 0);

      if (spots.isNotEmpty || ownBoards.isNotEmpty || savedBoards.isNotEmpty) {
        emit(state.copyWith(batchOffset: state.batchOffset + 1));
      }

      emit(state.copyWith(
          savedBoards: [...state.savedBoards, ...savedBoards],
          ownBoards: [...state.ownBoards, ...ownBoards],
          savedSpots: [...state.savedSpots, ...spots]));

      _search();

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

  Future<void> fetchMoreContent() async {
    emit(state.copyWith(status: HSSavedStatus.fetchingMoreContent));
    await _fetch();
    emit(state.copyWith(status: HSSavedStatus.idle));
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
    await _fetch();
  }

  @override
  Future<void> close() {
    state.textEditingController.dispose();
    return super.close();
  }
}
