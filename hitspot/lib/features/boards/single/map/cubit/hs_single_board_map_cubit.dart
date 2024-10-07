import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_single_board_map_state.dart';

class HSSingleBoardMapCubit extends Cubit<HSSingleBoardMapState> {
  HSSingleBoardMapCubit(
      {required this.mapWrapper, required this.board, required this.boardID})
      : super(const HSSingleBoardMapState()) {
    _init();
  }

  final String boardID;
  final HSBoard board;
  final Completer<GoogleMapController> controller = Completer();
  final HSMapWrapperCubit mapWrapper;
  final _locationRepository = app.locationRepository;
  final _databaseRepository = app.databaseRepository;
  final pageController = PageController();

  void _init() async {
    try {
      emit(state.copyWith(status: HSSingleBoardMapStatus.loading));
      //   await loadCurrentPosition();
      final spots =
          await _databaseRepository.boardFetchBoardSpots(boardID: boardID);
      mapWrapper.setOnMarkerTapped(_onMarkerTapped);
      mapWrapper.setVisibleSpots(spots);
      mapWrapper.updateMarkers(spots);
      //   loadMarkers();
      //   pageController.addListener(_pageListener);
      emit(state.copyWith(status: HSSingleBoardMapStatus.loaded));
      //   await _locationRepository.zoomToFitSpots(
      //       state.spots, await controller.future); // TODO: test this
    } catch (e) {
      HSDebugLogger.logError("Error initializing board map: $e");
      emit(state.copyWith(status: HSSingleBoardMapStatus.error));
    }
  }

  Future<void> loadCurrentPosition() async {
    try {
      final position =
          app.currentPosition ?? await _locationRepository.getCurrentLocation();
      emit(state.copyWith(currentPosition: position));
    } catch (_) {
      HSDebugLogger.logError("Error loading current position");
      rethrow;
    }
  }

  void _onMarkerTapped(HSSpot spot) {
    try {
      //   final index = state.spots.indexOf(spot);
      //   pageController.jumpToPage(index);
      mapWrapper.setSelectedSpot(spot);
      mapWrapper.updateMarkers();
      mapWrapper.zoomInToMarker();
    } catch (e) {
      HSDebugLogger.logError("Error tapping marker: $e");
    }
  }

  void resetCamera() async {
    try {
      await mapWrapper.zoomOut();
    } catch (_) {
      HSDebugLogger.logError("Error resetting camera");
    }
  }

  @override
  Future<void> close() {
    pageController.dispose();
    mapWrapper.close();
    return super.close();
  }
}
