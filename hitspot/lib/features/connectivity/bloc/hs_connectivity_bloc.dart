import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

part 'hs_connectivity_event.dart';
part 'hs_connectivity_state.dart';

class HSConnectivityLocationBloc
    extends Bloc<HSConnectivityLocationEvent, HSConnectivityLocationState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<Position>? _positionSubscription;

  HSConnectivityLocationBloc()
      : super(HSConnectivityLocationState(
            isConnected: false,
            isLocationServiceEnabled: false,
            isLocationSubscriptionActive: false)) {
    on<HSConnectivityCheckConnectivityEvent>(_onCheckConnectivity);
    on<HSConnectivityRequestLocationEvent>(_onRequestLocation);
    on<HSConnectivityCheckLocationServiceEvent>(_onCheckLocationService);
    on<HSConnectivityStartLocationSubscriptionEvent>(
        _onStartLocationSubscription);
    on<HSConnectivityStopLocationSubscriptionEvent>(
        _onStopLocationSubscription);

    // Initialize connectivity listener
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      add(HSConnectivityCheckConnectivityEvent());
    });

    add(HSConnectivityCheckConnectivityEvent());
    add(HSConnectivityCheckLocationServiceEvent());
  }

  Future<void> _onCheckConnectivity(HSConnectivityCheckConnectivityEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    final List<ConnectivityResult> result =
        await _connectivity.checkConnectivity();
    final bool isConnected = result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile);
    emit(state.copyWith(isConnected: isConnected));
  }

  Future<void> _onCheckLocationService(
      HSConnectivityCheckLocationServiceEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    final bool isEnabled = await Geolocator.isLocationServiceEnabled();
    emit(state.copyWith(isLocationServiceEnabled: isEnabled));
  }

  Future<void> _onRequestLocation(HSConnectivityRequestLocationEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    emit(state.copyWith(isLocationServiceEnabled: serviceEnabled));

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition();
      emit(state.copyWith(location: position));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _onStartLocationSubscription(
      HSConnectivityStartLocationSubscriptionEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    if (state.isLocationSubscriptionActive) {
      return; // Subscription is already active
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    emit(state.copyWith(isLocationServiceEnabled: serviceEnabled));

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _positionSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        emit(state.copyWith(
            location: position, isLocationSubscriptionActive: true));
      },
      onError: (error) {
        print('Error in location subscription: $error');
        emit(state.copyWith(isLocationSubscriptionActive: false));
      },
    );
  }

  Future<void> _onStopLocationSubscription(
      HSConnectivityStopLocationSubscriptionEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    emit(state.copyWith(isLocationSubscriptionActive: false));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _positionSubscription?.cancel();
    return super.close();
  }
}
