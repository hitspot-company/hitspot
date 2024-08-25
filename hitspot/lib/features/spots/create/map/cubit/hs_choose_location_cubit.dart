import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/features/map/search/view/map_search_delegate.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_choose_location_state.dart';

class HSChooseLocationCubit extends Cubit<HSChooseLocationState> {
  HSChooseLocationCubit(this.userLocation)
      : super(HSChooseLocationState(userLocation: userLocation)) {
    searchNode.addListener(() {
      final bool focused = searchNode.hasFocus;
      _toggleSearchfield(focused);
    });

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), () {
        fetchPredictions();
      });
    });
  }

  late final AnimationController animationController;
  Timer? _debounce;
  final Position userLocation;
  final HSLocationRepository _locationRepository = app.locationRepository;
  final searchController = TextEditingController();
  final searchNode = FocusNode();
  late Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Completer<GoogleMapController> get mapController => _mapController;
  String get query => searchController.text.trim();

  void onCameraMovement(LatLng newLocation) {
    emit(state.copyWith(cameraLocation: newLocation));
  }

  void initAnimationController(AnimationController controller) {
    animationController = controller;
  }

  void onCameraIdle() async {
    try {
      emit(state.copyWith(status: HSChooseLocationStatus.fetchingPlacemark));
      final LatLng cameraLocation = state.cameraLocation;
      final Placemark placemark = await _locationRepository.getPlacemark(
          cameraLocation.latitude, cameraLocation.longitude);
      final HSLocation selectedLocation = HSLocation(
          placemark: placemark,
          latitude: cameraLocation.latitude,
          longitude: cameraLocation.longitude);
      searchController.clear();
      HSDebugLogger.logInfo(
          "Camera idle: ${selectedLocation.placemark.name}, ${cameraLocation.latitude}, ${cameraLocation.longitude}");
      emit(state.copyWith(
          selectedLocation: selectedLocation,
          status: HSChooseLocationStatus.idle));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(state.copyWith(status: HSChooseLocationStatus.error));
    }
  }

  void fetchPredictions() async {
    try {
      emit(state.copyWith(status: HSChooseLocationStatus.fetchingPredictions));
      final List<HSPrediction> predictions =
          await _locationRepository.fetchPredictions(query, currentUser.uid!);
      emit(state.copyWith(
          predictions: predictions, status: HSChooseLocationStatus.idle));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  void onPredictionSelected(HSPrediction prediction) async {
    try {
      emit(state.copyWith(status: HSChooseLocationStatus.fetchingPlacemark));
      final HSPlaceDetails placeDetails = await _locationRepository
          .fetchPlaceDetails(placeID: prediction.placeID);
      final Placemark placemark = await _locationRepository.getPlacemark(
          placeDetails.latitude, placeDetails.longitude);
      final HSLocation selectedLocation = HSLocation(
          placemark: placemark,
          latitude: placeDetails.latitude,
          longitude: placeDetails.longitude);
      await animateCameraToNewLatLng(
          LatLng(selectedLocation.latitude, selectedLocation.longitude));
      searchNode.unfocus();
      emit(state.copyWith(
          selectedLocation: selectedLocation,
          status: HSChooseLocationStatus.idle));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(state.copyWith(status: HSChooseLocationStatus.error));
    }
  }

  Future<void> animateCameraToNewLatLng(LatLng location) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }

  void _toggleSearchfield(bool focused) =>
      emit(state.copyWith(isSearching: focused));

  void submit() async {
    final location = state.selectedLocation;
    final String address = await _locationRepository.getAddress(
        location!.latitude, location.longitude);
    navi.pop(state.selectedLocation!.copyWith(address: address));
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
        final HSPlaceDetails location = await app.locationRepository
            .fetchPlaceDetails(placeID: prediction.placeID);
        app.locationRepository.animateCameraToNewLatLng(
            mapController, LatLng(location.latitude, location.longitude), 14);
      }
    } catch (e) {
      HSDebugLogger.logError("Error fetching locations: $e");
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    if (_mapController.isCompleted) {
      _mapController = Completer<GoogleMapController>();
    }
    _mapController.complete(controller);
  }

  void cancel() => navi.pop(null);

  void resetPosition() async =>
      app.locationRepository.resetPosition(mapController);

  @override
  Future<void> close() {
    searchController.dispose();
    searchNode.dispose();
    return super.close();
  }
}
