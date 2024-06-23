import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/map/view/choose_location_provider.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

part 'hs_create_spot_state.dart';

class HSCreateSpotCubit extends Cubit<HSCreateSpotState> {
  HSCreateSpotCubit({this.prototype}) : super(const HSCreateSpotState()) {
    _initializeCreatingSpot();
  }

  final List<String> categories = [
    "graffiti",
    "monument",
    "park",
    "nightlife",
    "cafe",
    "bar",
  ];

  final HSSpot? prototype;
  final PageController pageController = PageController();
  final _locationRepository = app.locationRepository;
  String get titleHint =>
      state.title.isEmpty ? "The best spot on earth..." : state.title;

  String get descriptionHint =>
      state.description.isEmpty ? "Writings on the wall..." : state.description;

  void unfocus() => HSScaffold.hideInput();

  void nextPage() {
    unfocus();
    pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void prevPage() {
    unfocus();
    pageController.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _initializeCreatingSpot() async {
    try {
      emit(state.copyWith(
          status: HSCreateSpotStatus.requestingLocationPermission));
      await _requestLocationPermission();
      if (prototype == null) {
        await _chooseImages();
      }
      await _chooseLocation();
      if (prototype != null) {
        emit(
          state.copyWith(
            title: prototype!.title,
            description: prototype!.description,
          ),
        );
      }
    } catch (_) {
      HSDebugLogger.logError("Error: $_");
      navi.pop();
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      late final Position currentPosition;
      final bool isPermissionGranted =
          await _locationRepository.requestLocationPermission();
      if (!isPermissionGranted) {
        HSDebugLogger.logInfo("Permission not granted");
        currentPosition = kDefaultPosition;
      } else {
        currentPosition = await _locationRepository.getCurrentLocation();
      }
      emit(state.copyWith(
          currentLocation: currentPosition,
          status: HSCreateSpotStatus.choosingImages));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _chooseImages() async {
    try {
      final List<XFile> images = await app.pickers.multipleImages(
          cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
      emit(state.copyWith(
          images: images, status: HSCreateSpotStatus.choosingLocation));
    } catch (_) {
      throw Exception("No images selected: $_");
    }
  }

  Future<void> _chooseLocation() async {
    final HSLocation? result = await navi.pushPage(
        page: ChooseLocationProvider(
            initialUserLocation: state.currentLocation!));
    if (result != null) {
      HSDebugLogger.logSuccess("Received location: $result");
      emit(state.copyWith(
          spotLocation: result, status: HSCreateSpotStatus.fillingData));
    } else {
      throw "No location selected";
    }
  }

  void updateTitle(String value) => emit(state.copyWith(title: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value));
  void updateTagsQuery(String value) {
    emit(state.copyWith(tagsQuery: value));
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    try {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(const Duration(seconds: 2));
      final List<String> res =
          categories.where((e) => e.contains(state.tagsQuery)).toList();
      emit(state.copyWith(isLoading: false, queriedTags: res));
    } catch (_) {
      HSDebugLogger.logError("Could not fetch tags: $_");
      emit(state.copyWith(isLoading: false));
    }
  }

  List<File> get _xfilesToFiles =>
      state.images.map((e) => File(e.path)).toList();

  Future<void> submitSpot() async {
    try {
      emit(state.copyWith(status: HSCreateSpotStatus.submitting));
      final double lat = state.spotLocation!.latitude;
      final double long = state.spotLocation!.longitude;
      final HSSpot spot = HSSpot(
        title: state.title,
        description: state.description,
        geohash: _locationRepository.encodeGeoHash(lat, long),
        createdBy: currentUser.uid!,
        latitude: lat,
        longitude: long,
        address: state.spotLocation!.address,
      );
      HSDebugLogger.logInfo(spot.toString());
      late final String sid;
      if (prototype != null) {
        await app.databaseRepository
            .spotUpdate(spot: spot.copyWith(sid: prototype!.sid!));
        sid = prototype!.sid!;
      } else {
        sid = await app.databaseRepository.spotCreate(spot: spot);
        final List<String> urls = await app.storageRepository.spotUploadImages(
            files: _xfilesToFiles, uid: currentUser.uid!, sid: sid);
        HSDebugLogger.logSuccess("Uploaded images to the storage!");
        await app.databaseRepository.spotUploadImages(
            spotID: sid, imageUrls: urls, uid: currentUser.uid!);
        HSDebugLogger.logSuccess("Uploaded images to the database!");
        HSDebugLogger.logSuccess("Spot submitted: $sid");
      }
      HSDebugLogger.logSuccess("Spot created / updated: $sid");
      navi.toSpot(sid: sid, isSubmit: true);
      return;
    } catch (_) {
      HSDebugLogger.logError("Could not submit spot: $_");
    }
  }
}
