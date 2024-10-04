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
      await loadCurrentPosition();
      await loadSpots();
      mapWrapper.setOnMarkerTapped(_onMarkerTapped);
      loadMarkers();
      pageController.addListener(_pageListener);
      emit(state.copyWith(status: HSSingleBoardMapStatus.loaded));
      await _locationRepository.zoomToFitSpots(
          state.spots, await controller.future); // TODO: test this
    } catch (e) {
      HSDebugLogger.logError("Error initializing board map: $e");
      emit(state.copyWith(status: HSSingleBoardMapStatus.error));
    }
  }

  void _pageListener() async {
    final index = pageController.page?.round();
    if (index != null) {
      final spot = state.spots[index];
      _locationRepository.animateCameraToNewLatLng(
        controller,
        LatLng(spot.latitude!, spot.longitude!),
      );
      _generateNewMarkers(spot);
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

  Future<void> loadSpots() async {
    try {
      final spots =
          await _databaseRepository.boardFetchBoardSpots(boardID: boardID);
      emit(state.copyWith(spots: spots));
    } catch (_) {
      HSDebugLogger.logError("Error loading spots");
      rethrow;
    }
  }

  void loadMarkers() async {
    try {
      final markers = state.spots.map((e) {
        final markerIcon = app.assets.getMarkerIcon(e,
            level: HSSpotMarkerLevel.medium, isSelected: false);
        return Marker(
          markerId: MarkerId(e.sid!),
          position: LatLng(e.latitude!, e.longitude!),
          icon: markerIcon,
          onTap: () => _onMarkerTapped(e),
        );
      }).toSet();
      emit(state.copyWith(markers: markers));
    } catch (_) {
      HSDebugLogger.logError("Error loading markers");
      rethrow;
    }
  }

  void _onMarkerTapped(HSSpot spot) {
    try {
      final index = state.spots.indexOf(spot);
      pageController.jumpToPage(index);
      _generateNewMarkers(spot);
    } catch (_) {
      HSDebugLogger.logError("Error tapping marker");
    }
  }

  void _generateNewMarkers(HSSpot spot) {
    // List<Marker> markers = app.assets.generateMarkers(state.spots,
    //     currentPosition: state.currentPosition?.toLatLng,
    //     onTap: _onMarkerTapped,
    //     selectedSpotID: spot.sid);

    // emit(state.copyWith(markers: markers.toSet()));
  }

  void resetCamera() async {
    try {
      if (state.currentPosition != null && state.markers.isNotEmpty) {
        final HSSpot firstSpot = state.spots.first;
        _locationRepository.animateCameraToNewLatLng(
            controller, LatLng(firstSpot.latitude!, firstSpot.longitude!));
      }
    } catch (_) {
      HSDebugLogger.logError("Error resetting camera");
    }
  }
}
