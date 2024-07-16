import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/map/cubit/hs_choose_location_cubit.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_home_state.dart';

class HSHomeCubit extends Cubit<HSHomeState> {
  HSHomeCubit() : super(const HSHomeState()) {
    _fetchInitial();
  }

  late final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Completer<GoogleMapController> get mapController => _mapController;
  final _databaseRepository = app.databaseRepository;

  Future<void> _fetchInitial() async {
    try {
      emit(state.copyWith(status: HSHomeStatus.loading));
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
    } catch (_) {
      HSDebugLogger.logError("Error fetching initial data: $_");
    }
  }

  Future<void> handleRefresh() async {
    state.copyWith(status: HSHomeStatus.loading);
    await Future.delayed(const Duration(seconds: 2));
    state.copyWith(nearbySpots: [], tredingBoards: []);
    await _fetchInitial();
  }

  Future<void> _fetchNearbySpots() async {
    try {
      final currentPosition = state.currentPosition ??
          await app.locationRepository.getCurrentLocation();
      final lat = currentPosition.latitude;
      final long = currentPosition.longitude;
      final List<HSSpot> nearbySpots = await app.databaseRepository
          .spotFetchSpotsWithinRadius(lat: lat, long: long);
      placeMarkers();
      emit(state.copyWith(
          nearbySpots: nearbySpots, currentPosition: currentPosition));
    } catch (_) {
      HSDebugLogger.logError("Error fetching nearby spots: $_");
    }
  }

  Future<List<HSSpot>> _fetchTrendingSpots() async {
    try {
      final List<HSSpot> fetchedSpots =
          await _databaseRepository.spotFetchTrendingSpots();
      fetchedSpots.removeWhere((e) => state.nearbySpots.contains(e));
      for (var i = 0; i < fetchedSpots.length; i++) {
        for (var j = 0; j < state.nearbySpots.length; j++) {
          if (state.nearbySpots[j].sid == fetchedSpots[i].sid) {
            fetchedSpots.removeAt(i);
          }
        }
      }
      return fetchedSpots;
    } catch (e) {
      HSDebugLogger.logError("Error $e");
      return [];
    }
  }

  void placeMarkers() {
    final List<HSSpot> spots = state.nearbySpots;
    List<Marker> markers = app.assets.generateMarkers(
      spots,
      currentPosition: state.currentPosition?.toLatLng,
    );
    emit(state.copyWith(markers: markers));
  }

  Future<void> animateCameraToNewLatLng(LatLng location) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }
}
