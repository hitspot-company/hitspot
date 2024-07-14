import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_connectivity_event.dart';
part 'hs_connectivity_state.dart';

class ConnectivityLocationBloc
    extends Bloc<HSConnectivityLocationEvent, HSConnectivityLocationState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityLocationBloc()
      : super(HSConnectivityLocationState(isConnected: false)) {
    on<HSConnectivityLocationCheckConnectivityEvent>(_onCheckConnectivity);
    on<HSConnectivityRequestLocationEvent>(_onRequestLocation);

    // Initialize connectivity listener
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      add(HSConnectivityLocationCheckConnectivityEvent());
    });
  }

  Future<void> _onCheckConnectivity(
      HSConnectivityLocationCheckConnectivityEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    final List<ConnectivityResult> connectivityResult =
        await _connectivity.checkConnectivity();
    final isConnected =
        connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi);
    emit(state.copyWith(isConnected: isConnected));
  }

  Future<void> _onRequestLocation(HSConnectivityRequestLocationEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get current position
    try {
      final Position position = await Geolocator.getCurrentPosition();
      emit(state.copyWith(location: position));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
