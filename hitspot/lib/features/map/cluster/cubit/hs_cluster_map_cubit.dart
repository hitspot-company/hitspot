import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cluster/view/cluster_map_page.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/map/show_maps_choice_bottom_sheet.dart';
import 'package:hitspot/wrappers/map/cubit/hs_map_wrapper_cubit.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:pair/pair.dart';
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
  late final Position? _currentPosition;
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  final DraggableScrollableController scrollController =
      DraggableScrollableController();
  bool get isSheetExpanded => scrollController.size == SHEET_MAX_SIZE;

  bool isSpotSaved(HSSpot spot) {
    return state.savedSpots.contains(spot);
  }

  void _init() async {
    try {
      emit(state.copyWith(status: HSClusterMapStatus.loading));
      await _setCameraPositionAndVisibleSpots();
      mapWrapper.setOnMarkerTapped(_onMarkerTapped);
      mapWrapper.setOnCameraIdle(_onCameraIdle);
      final savedSpots = await _databaseRepository.spotFetchSaved(
          userID: app.currentUser.uid!);
      emit(state.copyWith(savedSpots: savedSpots));
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    } catch (e) {
      HSDebugLogger.logError("Failed to initialize map: $e");
      emit(state.copyWith(status: HSClusterMapStatus.error));
    }
  }

  Future<void> _setCameraPositionAndVisibleSpots() async {
    _currentPosition = await _getPosition();
    if (_currentPosition == null) return;
    final Pair<CameraPosition, List<HSSpot>>? initialCameraPositionAndSpots =
        await mapWrapper.getInitialCameraPositionAndSpots(_currentPosition);
    if (initialCameraPositionAndSpots == null) return;
    mapWrapper.setInitialCameraPosition(initialCameraPositionAndSpots.key);
    mapWrapper.setVisibleSpots(initialCameraPositionAndSpots.value);
  }

  // void _init() async {
  //   try {
  //     emit(state.copyWith(status: HSSingleBoardMapStatus.loading));
  //     final spots =
  //         await _databaseRepository.boardFetchBoardSpots(boardID: boardID);
  //     mapWrapper.setOnMarkerTapped(_onMarkerTapped);
  //     mapWrapper.setVisibleSpots(spots);
  //     mapWrapper.updateMarkers(spots);
  //     mapWrapper.setInitialCameraPosition(getInitialCameraPosition(spots));
  //     pageController.addListener(_pageListener);
  //     emit(state.copyWith(status: HSSingleBoardMapStatus.loaded));
  //   } catch (e) {
  //     HSDebugLogger.logError("Error initializing board map: $e");
  //     emit(state.copyWith(status: HSSingleBoardMapStatus.error));
  //   }
  // }

  void _onCameraIdle() async {
    final center = await mapWrapper.mapController.getVisibleRegion();
    final spots = await _databaseRepository.spotFetchInBounds(
      minLat: center.southwest.latitude,
      minLong: center.southwest.longitude,
      maxLat: center.northeast.latitude,
      maxLong: center.northeast.longitude,
    );
    mapWrapper.setVisibleSpots(spots);
    mapWrapper.updateMarkers();
  }

  void _placeMarkers() {
    final markers = state.visibleSpots.where((spot) {
      if (state.filters.isEmpty) return true;
      return spot.tags?.any((tag) => state.filters.contains(tag)) ?? false;
    }).map((e) {
      final markerIcon = app.assets.getMarkerIcon(e,
          level: state.markerLevel, isSelected: state.selectedSpot == e);
      return Marker(
        markerId: MarkerId(e.sid!),
        position: LatLng(e.latitude!, e.longitude!),
        icon: markerIcon,
        onTap: () => _onMarkerTapped(e),
      );
    }).toSet();
    emit(state.copyWith(markers: markers));
  }

  void _onMarkerTapped(HSSpot spot) async {
    mapWrapper.setSelectedSpot(spot);
    mapWrapper.updateMarkers();
    mapWrapper.zoomInToMarker(15.0);
    await scrollController.animateTo(1,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void closeSheet([bool toggleSelected = true]) async {
    await scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void resetSelectedSpot() {
    mapWrapper.setSelectedSpot(null);
  }

  Future<Position?> _getPosition() async {
    try {
      return app.currentPosition ??
          await _locationRepository.getCurrentLocation();
    } catch (e) {
      return null;
    }
  }

  List<String> fetchFilters() {
    final tags =
        state.visibleSpots.expand((spot) => spot.tags ?? []).toSet().toList();
    tags.sort();
    return tags.cast<String>();
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
        await _locationRepository.animateCameraToNewLatLng(mapController,
            LatLng(placeDetails.latitude, placeDetails.longitude), 13.0);
      }
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
  }

  void showFilters(BuildContext context) async {
    List<String> filterOptions = fetchFilters();

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return HSFilterPopup(
            filterOptions: filterOptions, selected: state.filters);
      },
    );

    if (result != null) {
      emit(state.copyWith(status: HSClusterMapStatus.refreshing));
      emit(state.copyWith(filters: result));
      _placeMarkers();
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    }
  }

  void map() {
    closeSheet();
  }

  void changeMapType() {
    emit(state.copyWith(status: HSClusterMapStatus.refreshing));
    emit(state.copyWith(
        mapType: state.mapType == MapType.normal
            ? MapType.satellite
            : MapType.normal));
    emit(state.copyWith(status: HSClusterMapStatus.loaded));
  }

  void findNearby() async {
    try {
      closeSheet();
      emit(state.copyWith(status: HSClusterMapStatus.nearby));
      final latlng = state.cameraPosition.target;
      final nearbySpots = await _databaseRepository.spotFetchClosest(
          lat: latlng.latitude, long: latlng.longitude);
      if (nearbySpots.isNotEmpty) {
        emit(state.copyWith(visibleSpots: nearbySpots));
        await _locationRepository.zoomToFitSpots(
            nearbySpots, await mapController.future,
            padding: .3);
        _placeMarkers();
      }
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    } catch (e) {
      HSDebugLogger.logError("Failed to get nearby spots: $e");
    }
  }

  Future<void> animateToCurrentLocation() async {
    try {
      final currentPosition = await _getPosition();
      _locationRepository.resetPosition(mapController, currentPosition);
    } catch (e) {
      HSDebugLogger.logError("Failed to animate to current location: $e");
    }
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
      emit(state.copyWith(status: HSClusterMapStatus.ignoringRefresh));
      final spot = state.selectedSpot;
      await _locationRepository.animateCameraToNewLatLng(
          mapController,
          LatLng(spot.latitude! - DEFAULT_MARKER_PADDING, spot.longitude!),
          18.0);
      closeSheet(false);
      emit(state.copyWith(status: HSClusterMapStatus.loaded));
    } catch (e) {
      HSDebugLogger.logError("Failed to show spot on map: $e");
    }
  }

  @override
  Future<void> close() async {
    await mapController.future.then((v) => v.dispose());
    await mapWrapper.close();
    scrollController.dispose();
    return super.close();
  }
}

extension on HSSpot {
  Marker toMarker(HSSpotMarkerLevel level, bool isSelected) {
    final markerIcon =
        app.assets.getMarkerIcon(this, level: level, isSelected: isSelected);
    return Marker(
      markerId: MarkerId(sid!),
      position: LatLng(latitude!, longitude!),
      icon: markerIcon,
    );
  }
}
