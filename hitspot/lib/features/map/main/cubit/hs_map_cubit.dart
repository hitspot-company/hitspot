import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hitspot/features/spots/create/map/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/widgets/map/hs_spot_info_window.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_state.dart';

class HSMapCubit extends Cubit<HSMapState> {
  HSMapCubit(this._initialCameraPosition) : super(const HSMapState()) {
    init();
  }

  final GlobalKey mapKey = GlobalKey();
  final _databaseRepository = app.databaseRepository;
  final Position? _initialCameraPosition;
  final Completer<GoogleMapController> controller = Completer();
  GlobalKey<ExpandableBottomSheetState> sheetKey = GlobalKey();
  ExpansionStatus get sheetStatus =>
      sheetKey.currentState?.expansionStatus ?? ExpansionStatus.contracted;

  Future<void> init() async {
    try {
      emit(state.copyWith(status: HSMapStatus.loading));
      late final LatLng cameraPosition;
      if (_initialCameraPosition != null) {
        cameraPosition = LatLng(
          _initialCameraPosition.latitude,
          _initialCameraPosition.longitude,
        );
      } else {
        cameraPosition =
            const LatLng(60.0, 60.0); // TODO: Change to place with most spots
      }
      emit(state.copyWith(
          cameraPosition: cameraPosition,
          currentPosition: _initialCameraPosition));
    } catch (e) {
      emit(state.copyWith(status: HSMapStatus.error));
      HSDebugLogger.logError("Error initializing map: $e");
    }
  }

  Future<void> fetchSpots() async {
    try {
      emit(state.copyWith(status: HSMapStatus.fetchingSpots));
      await Future.delayed(const Duration(seconds: 1));
      final LatLngBounds bounds = state.bounds!;
      final spots = await _databaseRepository.spotFetchSpotsInView(
        minLat: bounds.southwest.latitude,
        minLong: bounds.southwest.longitude,
        maxLat: bounds.northeast.latitude,
        maxLong: bounds.northeast.longitude,
      );
      HSDebugLogger.logSuccess("Fetched: ${spots.length} spots");
      spots.removeWhere((e) => state.spotsInView.contains(e));
      emit(state.copyWith(spotsInView: spots, status: HSMapStatus.success));
      placeMarkers();
    } catch (e) {
      HSDebugLogger.logError("Error fetching spots: $e");
    }
  }

  void onMapCreated(GoogleMapController cont) async {
    controller.complete(cont);
    await app.theme.applyMapDarkStyle(controller);
  }

  void onCameraIdle() async {
    final bounds =
        await controller.future.then((value) => value.getVisibleRegion());
    toggleIsMoving(false);
    emit(state.copyWith(status: HSMapStatus.fetchingSpots, bounds: bounds));
    fetchSpots();
  }

  void placeMarkers() {
    final List<HSSpot> spots = state.spotsInView;
    List<Marker> markers = app.assets.generateMarkers(
        spots, state.currentPosition?.toLatLng, onMarkerTapped);
    emit(state.copyWith(markersInView: markers));
  }

  void toggleIsMoving([bool? isMoving]) {
    emit(state.copyWith(isMoving: isMoving ?? !state.isMoving));
  }

  void onMarkerTapped(HSSpot spot) {
    animateCamera(LatLng(spot.latitude!, spot.longitude!), zoom: 19.0);
    setSelectedSpot(spot);
    closeSheet();
  }

  void updateSheetExpansionStatus() => emit(state.copyWith(
      sheetExpansionStatus: sheetKey.currentState?.expansionStatus,
      selectedSpot: state.selectedSpot));

  void closeSheet() {
    if (sheetKey.currentState?.expansionStatus == ExpansionStatus.expanded) {
      sheetKey.currentState?.contract();
    }
  }

  void setSelectedSpot(HSSpot spot) {
    emit(state.copyWith(selectedSpot: spot));
  }

  void clearSelectedSpot() {
    emit(state.copyWith(selectedSpot: const HSSpot(sid: "clear")));
  }

  void defaultButtonCallback() {
    if (sheetKey.currentState?.expansionStatus == ExpansionStatus.contracted) {
      navi.pop();
      return;
    }
    closeSheet();
  }

  Future<void> animateCamera(LatLng newLatLng, {double? zoom}) async {
    toggleIsMoving(true);
    await app.locationRepository
        .animateCameraToNewLatLng(controller, newLatLng, zoom);
  }

  Future<void> searchLocation(BuildContext context) async {
    try {
      final mapSearchCubit = BlocProvider.of<HSMapSearchCubit>(context);
      final HSPrediction? prediction = await showSearch(
        context: context,
        delegate: MapSearchDelegate(mapSearchCubit),
      );
      // Fetched properly
      if (prediction != null && prediction.placeID.isNotEmpty) {
        if (sheetStatus == ExpansionStatus.expanded) {
          sheetKey.currentState?.contract();
        }
        final HSPlaceDetails location = await app.locationRepository
            .fetchPlaceDetails(placeID: prediction.placeID);
        app.locationRepository.animateCameraToNewLatLng(
            controller, LatLng(location.latitude, location.longitude));
      }
    } catch (e) {
      HSDebugLogger.logError("Error fetching locations: $e");
    }
  }
}
