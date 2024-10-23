import 'dart:async';
import 'dart:math' as math;
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
  final HSMapWrapperCubit mapWrapper;
  final _locationRepository = app.locationRepository;
  final _databaseRepository = app.databaseRepository;
  final pageController = PageController();

  List<HSSpot> get spots => mapWrapper.state.visibleSpots;

  void _init() async {
    try {
      emit(state.copyWith(status: HSSingleBoardMapStatus.loading));
      final spots =
          await _databaseRepository.boardFetchBoardSpots(boardID: boardID);
      mapWrapper.init(
        onMarkerTapped: _onMarkerTapped,
        visibleSpots: spots,
        initialCameraPosition: getInitialCameraPosition(spots),
      );
      pageController.addListener(_pageListener);
      emit(state.copyWith(status: HSSingleBoardMapStatus.loaded));
    } catch (e) {
      HSDebugLogger.logError("Error initializing board map: $e");
      emit(state.copyWith(status: HSSingleBoardMapStatus.error));
    }
  }

  CameraPosition getInitialCameraPosition(List<HSSpot> spots) {
    const padding = 0.1;
    final latlngs =
        spots.map((e) => LatLng(e.latitude!, e.longitude!)).toList();
    final bounds = _locationRepository.getLatLngBounds(latlngs);
    final center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    final latDelta = bounds.northeast.latitude - bounds.southwest.latitude;
    final lngDelta = bounds.northeast.longitude - bounds.southwest.longitude;

    final maxDelta = latDelta > lngDelta ? latDelta : lngDelta;
    final zoom = math.log(360 / (maxDelta + padding)) / math.ln2;

    return CameraPosition(
      target: center,
      zoom: zoom,
    );
  }

  void _pageListener() {
    final index = pageController.page?.round() ?? 0;
    final spot = mapWrapper.state.visibleSpots[index];
    mapWrapper.setSelectedSpot(spot);
    mapWrapper.updateMarkers();
    mapWrapper.zoomInToMarker(15.0);
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
      final index = spots.indexOf(spot);
      if (index == pageController.page?.round()) {
        final spot = mapWrapper.state.visibleSpots[index];
        mapWrapper.setSelectedSpot(spot);
        mapWrapper.updateMarkers();
        mapWrapper.zoomInToMarker(15.0);
      } else {
        pageController.jumpToPage(index);
      }
    } catch (e) {
      HSDebugLogger.logError("Error tapping marker: $e");
    }
  }

  void resetCamera() async {
    try {
      await mapWrapper.moveCamera(mapWrapper.initialCameraPosition.target,
          mapWrapper.initialCameraPosition.zoom);
    } catch (_) {
      HSDebugLogger.logError("Error resetting camera");
    }
  }

  @override
  Future<void> close() async {
    pageController.dispose();
    await mapWrapper.close();
    return super.close();
  }
}
