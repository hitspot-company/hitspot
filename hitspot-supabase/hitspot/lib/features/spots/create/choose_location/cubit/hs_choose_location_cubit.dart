import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_choose_location_state.dart';

class HsChooseLocationCubit extends Cubit<HsChooseLocationState> {
  HsChooseLocationCubit(this.initialUserLocation)
      : super(HsChooseLocationState(usersLocation: initialUserLocation)) {
    searchNode.addListener(() {
      final bool focused = searchNode.hasFocus;
      _toggleSearchfield(focused);
      HSDebugLogger.logInfo(focused ? "Focused" : "Unfocused");
    });
  }

  final Position initialUserLocation;
  late final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Completer<GoogleMapController> get mapController => _mapController;
  final HSLocationRepository _locationRepository = app.locationRepository;
  final FocusNode searchNode = FocusNode();

  void _toggleSearchfield(bool focused) =>
      emit(state.copyWith(isSearching: focused));

  void setLocationChanged({required LatLng location}) async {
    try {
      final Placemark selectedLocation = await _locationRepository.getPlacemark(
          location.latitude, location.longitude);
      emit(state.copyWith(
          chosenLocation: selectedLocation, selectedLocation: location));
    } catch (_) {
      HSDebugLogger.logError("Could not change selected location: $_");
    }
  }

  void locationChanged({required LatLng location}) {
    emit(state.copyWith(location: location));
  }

  Future<void> animateCameraToNewLatLng(LatLng location) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }

  void submitLocation() {
    navi.pop(HSLocation(
      latitude: state.selectedLocation.latitude,
      longitude: state.selectedLocation.longitude,
      placemark: state.chosenLocation ?? const Placemark(name: "Test"),
    ));
  }

  void backToHome() => navi.router.go('/');

  @override
  Future<void> close() {
    searchNode.removeListener;
    return super.close();
  }
}
