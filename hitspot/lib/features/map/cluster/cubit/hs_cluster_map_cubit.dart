import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/map/show_maps_choice_bottom_sheet.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:share_plus/share_plus.dart';

part 'hs_cluster_map_state.dart';

class HsClusterMapCubit extends Cubit<HsClusterMapState> {
  HsClusterMapCubit(this.mapWrapper) : super(const HsClusterMapState()) {
    _init();
  }

  final HSMapWrapperCubit mapWrapper;

  static const SHEET_MAX_SIZE = .8;
  static const SHEET_MIN_SIZE = .3;
  static const DEFAULT_MARKER_PADDING = .0001;

  final _databaseRepository = app.databaseRepository;
  final _locationRepository = app.locationRepository;
  final DraggableScrollableController scrollController =
      DraggableScrollableController();
  bool get isSheetExpanded => scrollController.size == SHEET_MAX_SIZE;

  bool isSpotSaved(HSSpot spot) {
    return state.savedSpots.contains(spot);
  }

  void _init() async {
    try {
      emit(state.copyWith(status: HSClusterMapStatus.loading));
      await _initMapWrapper();
      final savedSpots = await _databaseRepository.spotFetchSaved(
          userID: app.currentUser.uid!);
      emit(state.copyWith(savedSpots: savedSpots));
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    } catch (e) {
      HSDebugLogger.logError("Failed to initialize map: $e");
      emit(state.copyWith(status: HSClusterMapStatus.error));
    }
  }

  Future<void> _initMapWrapper() async {
    final currentPosition = await _getPosition();
    final initialCameraPositionAndSpots = await _locationRepository
        .getInitialCameraPositionAndSpots(currentPosition);
    mapWrapper.init(
      onMarkerTapped: _onMarkerTapped,
      onCameraIdle: _onCameraIdle,
      onCameraMove: _onCameraMove,
      visibleSpots: initialCameraPositionAndSpots?.value,
      initialCameraPosition: initialCameraPositionAndSpots?.key,
    );
  }

  Timer? _timer;

  void _onCameraIdle() async {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(status: HSClusterMapStatus.refreshing));
      final center = await mapWrapper.mapController.getVisibleRegion();
      final spots = await _databaseRepository.spotFetchInBounds(
        minLat: center.southwest.latitude,
        minLong: center.southwest.longitude,
        maxLat: center.northeast.latitude,
        maxLong: center.northeast.longitude,
      );
      mapWrapper.setVisibleSpots(spots);
      mapWrapper.updateMarkers();
      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    });
  }

  void _onMarkerTapped(HSSpot spot) async {
    mapWrapper.setSelectedSpot(spot);
    mapWrapper.updateMarkers();
    mapWrapper.zoomInToMarker(15.0);
    await scrollController.animateTo(1,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void closeSheet([bool toggleSelected = true]) async {
    if (toggleSelected) {
      mapWrapper.clearSelectedSpot();
    }
    await scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onCameraMove(CameraPosition position) {
    if (isSheetExpanded) closeSheet(false);
    _timer?.cancel();
  }

  Future<Position?> _getPosition() async {
    try {
      return app.currentPosition ??
          await _locationRepository.getCurrentLocation();
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchSearch(BuildContext context) async {
    try {
      final HSPrediction? result = await showSearch(
        context: context,
        delegate: MapSearchDelegate(HSMapSearchCubit()),
      );
      if (result != null && result.placeID.isNotEmpty) {
        final HSPlaceDetails placeDetails = await _locationRepository
            .fetchPlaceDetails(placeID: result.placeID);
        closeSheet();
        HSScaffold.hideInput();
        await mapWrapper.moveCamera(
            LatLng(placeDetails.latitude, placeDetails.longitude), 13.0);
      }
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
  }

  void map() {
    closeSheet();
  }

  void changeMapType() {
    mapWrapper.switchMapType();
  }

  Future<void> shareSpot(HSSpot spot) async {
    try {
      emit(state.copyWith(status: HSClusterMapStatus.sharing));
      await Share.share("https://hitspot.app/spot/${spot.sid}",
          subject: "Hey! Check out ${spot.title} at ${spot.getAddress}");
    } catch (_) {
      HSDebugLogger.logError("Could not share spot: $_");
    }
    emit(state.copyWith(status: HSClusterMapStatus.loaded));
  }

  Future<void> saveSpot(HSSpot spot) async {
    try {
      emit(state.copyWith(status: HSClusterMapStatus.saving));
      bool isSaved = await app.databaseRepository
          .spotSaveUnsave(spot: spot, user: app.currentUser);
      if (isSaved) {
        emit(state.copyWith(savedSpots: [...state.savedSpots, spot]));
      } else {
        emit(state.copyWith(
            savedSpots:
                state.savedSpots.where((e) => e.sid != spot.sid).toList()));
      }
    } catch (e) {
      HSDebugLogger.logError("$e");
    }
    emit(state.copyWith(status: HSClusterMapStatus.loaded));
  }

  Future<void> launchMaps(HSSpot spot) async {
    try {
      emit(state.copyWith(status: HSClusterMapStatus.openingDirections));
      showMapsChoiceBottomSheet(
          context: app.context,
          coords: LatLng(spot.latitude!, spot.longitude!),
          description: spot.getAddress,
          title: spot.title!);
    } catch (e) {
      HSDebugLogger.logError("Failed to launch maps: $e");
    }
    emit(state.copyWith(status: HSClusterMapStatus.loaded));
  }

  void showSpotOnMap() async {
    try {
      final spot = mapWrapper.state.selectedSpot;
      await mapWrapper.moveCamera(
          LatLng(spot.latitude! - DEFAULT_MARKER_PADDING, spot.longitude!),
          18.0);
      closeSheet(false);
    } catch (e) {
      HSDebugLogger.logError("Failed to show spot on map: $e");
    }
  }

  @override
  Future<void> close() async {
    await mapWrapper.close();
    scrollController.dispose();
    return super.close();
  }
}
