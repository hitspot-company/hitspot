import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_network_repository/hs_network_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart';

part 'hs_add_spot_cubit_state.dart';

class HSAddSpotCubit extends Cubit<HSAddSpotCubitState> {
  final HSDatabaseRepository _hsDatabaseRepository;
  final HSLocationRepository _hsLocationRepository;
  final HSNetworkRepository _hsNetworkRepository;

  HSAddSpotCubit(this._hsDatabaseRepository, this._hsLocationRepository,
      this._hsNetworkRepository)
      : super(HsAddSpotCubitInitial());

  Future<void> createSpot() async {
    HSDebugLogger.logInfo("Creating spot");
    await _hsDatabaseRepository.createSpot(
      title: state.title,
      images: state.images,
    );
  }

  Future<LocationData?> getCurrentLocation() async {
    HSDebugLogger.logInfo("Getting current location.");
    LocationData? location = await _hsLocationRepository.getCurrentLocation();

    emit(state.copyWith(
        isLoading: false,
        location: LatLng(location?.latitude ?? 0, location?.longitude ?? 0)));
  }

  Future<List<String>?> makeLocationQuery(String query) async {
    return await _hsNetworkRepository.makeLocationQuery(query);
  }

  void isLoadingChanged({required bool isLoading}) {
    emit(state.copyWith(isLoading: isLoading));
  }

  void locationChanged({required LatLng location}) {
    emit(state.copyWith(location: location));
  }

  void setLocationChanged({required LatLng location}) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);

    LocationData? userLocation =
        await _hsLocationRepository.getCurrentLocation();

    if (userLocation == null ||
        userLocation.latitude == null ||
        userLocation.longitude == null) {
      return;
    }

    double distance = Geolocator.distanceBetween(userLocation.latitude!,
        userLocation.longitude!, location.latitude, location.longitude);

    // format distance
    String formattedDistance;

    if (distance >= 1000) {
      double distanceInKm = distance / 1000;
      formattedDistance = "${distanceInKm.toStringAsFixed(0)} km";
    } else {
      formattedDistance = "${distance.toStringAsFixed(0)} meters";
    }

    emit(state.copyWith(
        selectedLocation: location,
        selectedLocationStreetName: placemarks[0].street,
        selectedLocationDistance: formattedDistance));
  }

  void titleChanged({required String title}) {
    emit(
      state.copyWith(title: title),
    );
  }

  void imagesChanged({required List<XFile> images}) {
    emit(state.copyWith(images: images));
  }
}
