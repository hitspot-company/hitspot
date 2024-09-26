import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/cubit/hs_spot_upload_cubit.dart';
import 'package:hitspot/features/spots/create/map/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/utils/upgrader/hs_upgrade_messages.dart.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:upgrader/upgrader.dart';

part 'hs_home_state.dart';

class HSHomeCubit extends Cubit<HSHomeState> {
  HSHomeCubit() : super(const HSHomeState()) {
    _init();
  }

  late final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Completer<GoogleMapController> get mapController => _mapController;
  final _databaseRepository = app.databaseRepository;

  bool get isPageEmpty =>
      state.trendingSpots.isEmpty &&
      state.nearbySpots.isEmpty &&
      state.trendingBoards.isEmpty;

  void lateFetchNearby() => _fetchNearbySpots();

  String get appcastURL =>
      'https://hitspot.app/.well-known/${Platform.isIOS ? "ios" : "android"}-appcast.xml';
  late final Upgrader upgrader;

  void _init() async {
    emit(state.copyWith(status: HSHomeStatus.loading));
    await fetchUpdateInfo();
    if (state.status != HSHomeStatus.updateRequired) {
      await _fetchInitial();
    }
  }

  Future<void> fetchUpdateInfo() async {
    upgrader = Upgrader(
      messages: HSUpgradeMessages(),
      storeController: UpgraderStoreController(
        onAndroid: () => UpgraderAppcastStore(appcastURL: appcastURL),
        oniOS: () => UpgraderAppcastStore(appcastURL: appcastURL),
      ),
    );
    await upgrader.initialize();
    final updateVersionInfo = upgrader.versionInfo;
    if (updateVersionInfo != null &&
        updateVersionInfo.installedVersion !=
            updateVersionInfo.appStoreVersion &&
        upgrader.shouldDisplayUpgrade()) {
      emit(state.copyWith(status: HSHomeStatus.updateRequired));
    }
  }

  Future<void> _fetchInitial() async {
    try {
      final List<HSBoard> tredingBoards =
          await app.databaseRepository.boardFetchTrendingBoards();
      final permission = app.isLocationServiceEnabled;
      HSDebugLogger.logInfo("Permission: $permission");
      HSDebugLogger.logInfo("Current Position: ${app.currentPosition}");
      if (permission) {
        await _fetchNearbySpots();
      }
      final List<HSSpot> trendingSpots = await _fetchTrendingSpots();
      emit(state.copyWith(
          status: HSHomeStatus.idle,
          tredingBoards: tredingBoards,
          trendingSpots: trendingSpots));
      HSDebugLogger.logInfo("Initial data fetched");
    } catch (e) {
      HSDebugLogger.logError("Error fetching initial data: $e");
    }
  }

  bool updateRefresh() {
    handleRefresh();
    return (true);
  }

  void showUploadBar() {
    emit(state.copyWith(hideUploadBar: false));
  }

  void hideUploadBar() {
    if (app.context.read<HSSpotUploadCubit>().state.status ==
        HSUploadStatus.success) {
      app.context.read<HSSpotUploadCubit>().reset();
      showUploadBar();
    } else {
      emit(state.copyWith(hideUploadBar: true));
    }
  }

  Future<void> handleRefresh([bool shouldHideUploadBar = false]) async {
    state.copyWith(status: HSHomeStatus.loading);
    if (shouldHideUploadBar) {
      hideUploadBar();
    }
    state.copyWith(
      status: HSHomeStatus.loading,
      tredingBoards: const [],
      markers: const [],
      nearbySpots: const [],
      trendingSpots: const [],
      currentPosition: null,
    );
    await _fetchInitial();
    if (state.currentPosition != null) {
      app.locationRepository.animateCameraToNewLatLng(
          mapController, state.currentPosition!.toLatLng, 16.0);
    }
  }

  Future<void> _fetchNearbySpots() async {
    try {
      final currentPosition = state.currentPosition ??
          await app.locationRepository.getCurrentLocation();
      final lat = currentPosition.latitude;
      final long = currentPosition.longitude;
      final List<HSSpot> nearbySpots = await app.databaseRepository
          .spotFetchSpotsWithinRadius(
              lat: lat,
              long: long,
              radius: 500 * 1000); // TODO: Change radius (now its 500km)
      emit(state.copyWith(
          nearbySpots: nearbySpots, currentPosition: currentPosition));
      placeMarkers();
    } catch (_) {
      HSDebugLogger.logError("Error fetching nearby spots: $_");
    }
  }

  Future<List<HSSpot>> _fetchTrendingSpots() async {
    try {
      final List<HSSpot> fetchedSpots =
          await _databaseRepository.spotFetchTrendingSpots();
      fetchedSpots.removeWhere((e) => state.nearbySpots.contains(e));
      return fetchedSpots;
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      return [];
    }
  }

  void placeMarkers() {
    // final List<HSSpot> spots = state.nearbySpots;
    // List<Marker> markers = app.assets.generateMarkers(
    //   spots,
    //   currentPosition: state.currentPosition?.toLatLng,
    // );
    // emit(state.copyWith(markers: markers));
  }

  Future<void> animateCameraToNewLatLng(LatLng location) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }
}
