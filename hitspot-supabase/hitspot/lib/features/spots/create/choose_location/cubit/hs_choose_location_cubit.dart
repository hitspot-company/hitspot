import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_choose_location_state.dart';

class HsChooseLocationCubit extends Cubit<HsChooseLocationState> {
  HsChooseLocationCubit(this.initialUserLocation)
      : super(HsChooseLocationState(userLocation: initialUserLocation)) {
    searchNode.addListener(() {
      final bool focused = searchNode.hasFocus;
      _toggleSearchfield(focused);
      HSDebugLogger.logInfo(focused ? "Focused" : "Unfocused");
    });

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), () {
        fetchPredictions();
      });
    });
  }

  Timer? _debounce;
  final Position initialUserLocation;
  final TextEditingController searchController = TextEditingController();
  late final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Completer<GoogleMapController> get mapController => _mapController;
  final HSLocationRepository _locationRepository = app.locationRepository;
  final FocusNode searchNode = FocusNode();

  void _toggleSearchfield(bool focused) =>
      emit(state.copyWith(isSearching: focused));

  void setLocationChanged({required LatLng location}) async {
    try {
      final Placemark placemark = await _locationRepository.getPlacemark(
          location.latitude, location.longitude);
      searchController.text = placemark.name!;
      emit(
        state.copyWith(
          selectedLocation: HSLocation(
              placemark: placemark,
              latitude: location.latitude,
              longitude: location.longitude),
        ),
      );
    } catch (_) {
      HSDebugLogger.logError("Could not change selected location: $_");
    }
  }

  void cameraLocationChanged({required LatLng location}) {
    emit(state.copyWith(cameraLocation: location));
  }

  Future<void> animateCameraToNewLatLng(LatLng location) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }

  void submitLocation() {
    final selectedLocation = state.selectedLocation;
    navi.pop(selectedLocation);
  }

  Future<void> selectPrediction(HSPrediction prediction) async {
    try {
      final HSPlaceDetails placeDetails = await app.locationRepository
          .fetchPlaceDetails(placeID: prediction.placeID);
      setLocationChanged(
          location: LatLng(placeDetails.latitude, placeDetails.longitude));
    } catch (_) {
      HSDebugLogger.logError("Error selecting prediction: $_");
    }
  }

  Future<void> fetchPredictions() async {
    final query = searchController.text;
    final uid = currentUser.uid!;
    final List<HSPrediction> predictions =
        await app.locationRepository.fetchPredictions(query, uid);
    emit(state.copyWith(predictions: predictions));
  }

  void clearPredictions() => emit(state.copyWith(predictions: []));

  void backToHome() => navi.router.go('/');

  @override
  Future<void> close() {
    searchNode.dispose();
    searchController.dispose();
    _debounce?.cancel();
    return super.close();
  }
}

// What needs to be kept track of
// 1. User Location
// 2. Selected Location


// Ways to change the address
// 1. Move the pin => changes thr