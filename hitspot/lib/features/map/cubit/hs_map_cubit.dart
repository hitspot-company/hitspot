import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_map_state.dart';

class HSMapCubit extends Cubit<HSMapState> {
  HSMapCubit(this._initialCameraPosition) : super(const HSMapState()) {
    init();
  }

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
      placeMarkers();
      emit(state.copyWith(spotsInView: spots, status: HSMapStatus.success));
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
    emit(state.copyWith(status: HSMapStatus.fetchingSpots, bounds: bounds));
    fetchSpots();
  }

  void placeMarkers() {
    final List<HSSpot> spots = state.spotsInView;
    List<Marker> markers = spots
        .map((e) => Marker(
            markerId: MarkerId(e.sid!),
            position: LatLng(e.latitude!, e.longitude!)))
        .toList();
    emit(state.copyWith(markersInView: markers));
  }

  void updateSheetExpansionStatus() => emit(state.copyWith(
      sheetExpansionStatus: sheetKey.currentState?.expansionStatus));

  void defaultButtonCallback() {
    if (sheetKey.currentState?.expansionStatus == ExpansionStatus.contracted) {
      navi.pop();
      return;
    }
    sheetKey.currentState?.contract();
  }
}
