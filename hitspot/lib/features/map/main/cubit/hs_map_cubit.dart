import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
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
  final _locationRepository = app.locationRepository;
  late final BitmapDescriptor _generalMarker;

  Future<void> init() async {
    try {
      emit(state.copyWith(status: HSMapStatus.loading));
      late final LatLng cameraPosition;
      final imageConfiguration = createLocalImageConfiguration(app.context);
      _generalMarker = await BitmapDescriptor.asset(
          imageConfiguration, HSAssets.generalMarker);
      if (_initialCameraPosition != null) {
        cameraPosition = LatLng(
          _initialCameraPosition.latitude,
          _initialCameraPosition.longitude,
        );
      } else if (app.currentPosition != null) {
        cameraPosition = LatLng(
            app.currentPosition!.latitude, app.currentPosition!.longitude);
      } else {
        cameraPosition = LatLng(kDefaultLatitude,
            kDefaultLongitude); // TODO: Change to place with most spots
      }
      emit(state.copyWith(cameraPosition: cameraPosition));
      await _fetchClosestSpots();
      emit(state.copyWith(
          cameraPosition: cameraPosition,
          currentPosition: _initialCameraPosition));
    } catch (e) {
      emit(state.copyWith(status: HSMapStatus.error));
      HSDebugLogger.logError("Error initializing map: $e");
    }
  }

  Future<void> _fetchClosestSpots() async {
    try {
      emit(state.copyWith(status: HSMapStatus.fetchingSpots));
      final List<Map<String, dynamic>> spots =
          await supabase.rpc('spot_fetch_closest', params: {
        'p_user_lat': state.cameraPosition!.latitude,
        'p_user_long': state.cameraPosition!.longitude,
        'p_batch_size': 20,
        'p_batch_offset': 0,
        'p_distance_km': 1000,
      });
      final res = spots.map((e) => HSSpot.deserializeWithAuthor(e)).toList();
      await _locationRepository.zoomToFitSpots(res, await controller.future,
          currentPosition: app.currentPosition);
      emit(state.copyWith(spotsInView: res));
      placeMarkers();
    } catch (e) {
      HSDebugLogger.logError("Error fetching spots: $e");
    }
  }

  // Function to calculate LatLngBounds and zoom out to fit all spots

  Future<void> fetchSpots() async {
    try {
      emit(state.copyWith(status: HSMapStatus.fetchingSpots));
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
  }

  void onCameraIdle() async {
    final bounds =
        await controller.future.then((value) => value.getVisibleRegion());
    toggleIsMoving(false);
    emit(state.copyWith(status: HSMapStatus.fetchingSpots, bounds: bounds));
    fetchSpots();
  }

  Future<BitmapDescriptor> getImage(String assetPath) async {
    final asset = await rootBundle.load(assetPath);
    final icon = BitmapDescriptor.bytes(asset.buffer.asUint8List(),
        height: 100, width: 100);
    return icon;
  }

  void placeMarkers() {
    final List<HSSpot> spots = state.spotsInView;
    final marker = _generalMarker;
    final List<Marker> markers = spots
        .map(
          (e) => Marker(
            markerId: MarkerId(e.sid!),
            position: LatLng(e.latitude!, e.longitude!),
            icon: marker,
            onTap: () => onMarkerTapped(e),
          ),
        )
        .toList();
    // List<Marker> markers = app.assets.generateMarkers(spots,
    //     currentPosition: state.currentPosition?.toLatLng,
    //     onTap: onMarkerTapped,
    //     selectedSpotID: state.selectedSpot.sid);
    emit(state.copyWith(markersInView: markers));
  }

  void toggleIsMoving([bool? isMoving]) {
    emit(state.copyWith(isMoving: isMoving ?? !state.isMoving));
  }

  void onMarkerTapped(HSSpot spot) {
    animateCamera(LatLng(spot.latitude!, spot.longitude!), zoom: 19.0);
    setSelectedSpot(spot);
    closeSheet();
    placeMarkers();
  }

  void updateSheetExpansionStatus() => emit(state.copyWith(
      sheetExpansionStatus: sheetKey.currentState?.expansionStatus,
      selectedSpot: state.selectedSpot));

  void closeSheet() {
    if (sheetKey.currentState?.expansionStatus != ExpansionStatus.contracted) {
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
            controller, LatLng(location.latitude, location.longitude), 14);
      }
    } catch (e) {
      HSDebugLogger.logError("Error fetching locations: $e");
    }
  }

  Future<void> updateInfoWindowsWithMarkers(CameraPosition pos) async {
    if (state.infoWindowProvider.showInfoWindowData) {
      final GoogleMapController cont = await controller.future;
      final infoWindow = await state.infoWindowProvider
          .updateInfoWindow(cont, latLng: pos.target);
      emit(state.copyWith(infoWindowProvider: infoWindow));
    }
  }

  void updateInfoWindowVisibility(bool visibility,
      [bool ignoreAutomaticMovement = true]) {
    final infoWindow = state.infoWindowProvider.updateVisibility(visibility);
    emit(state.copyWith(infoWindowProvider: infoWindow));
  }

  void hideInfoWindow() {
    final infoWindow = state.infoWindowProvider.updateVisibility(false);
    emit(state.copyWith(infoWindowProvider: infoWindow));
  }

  void resetPosition() async {
    HSDebugLogger.logInfo("Reseting pos");
    _locationRepository.resetPosition(
        controller, await _locationRepository.getCurrentLocation());
  }
}
