import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';

part 'hs_connectivity_event.dart';
part 'hs_connectivity_state.dart';

class HSConnectivityLocationBloc
    extends Bloc<HSConnectivityLocationEvent, HSConnectivityLocationState> {
  final Connectivity _connectivity = Connectivity();
  final HSDatabaseRepsitory _databaseRepsitory = app.databaseRepository;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<dynamic>? _fcmTokenSubscription;

  HSConnectivityLocationBloc()
      : super(HSConnectivityLocationState(
          isConnected: false,
          isLocationServiceEnabled: false,
          isLocationSubscriptionActive: false,
        )) {
    on<HSConnectivityCheckConnectivityEvent>(_onCheckConnectivity);
    on<HSConnectivityRequestLocationEvent>(_onRequestLocation);
    on<HSConnectivityCheckLocationServiceEvent>(_onCheckLocationService);
    on<HSConnectivityLocationChangedEvent>((event, emit) {
      emit(state.copyWith(location: event.location));
      // TODO: Implement location gathering system
    });
    on<HSConnectivityStopLocationSubscriptionEvent>(
        _onStopLocationSubscription);

    add(HSConnectivityCheckConnectivityEvent());
    add(HSConnectivityCheckLocationServiceEvent());
    add(HSConnectivityRequestLocationEvent());

    if (state.isLocationServiceEnabled) {
      _connectivitySubscription = _connectivity.onConnectivityChanged
          .listen((List<ConnectivityResult> result) {
        add(HSConnectivityCheckConnectivityEvent());
      });

      _positionSubscription =
          Geolocator.getPositionStream().listen((Position position) {
        HSDebugLogger.logInfo("Location changed: $position");
        add(HSConnectivityLocationChangedEvent(position));
      });

      _fcmTokenSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
        HSDebugLogger.logInfo("FCM token changed!");
        add(HSConnectivityFcmTokenChangedEvent(fcmToken));
        await _databaseRepsitory.notifactionChangeFcmToken(
            userID: app.currentUser.uid ?? "", fcmToken: fcmToken);
      });
    } else {
      add(HSConnectivityLocationChangedEvent(Position(
        longitude: 12.496366,
        latitude: 41.902782,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      )));
    }
    add(HSConnectivityRequestNotificationPermissionEvent());
  }

  Future<void> _onCheckConnectivity(HSConnectivityCheckConnectivityEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    final List<ConnectivityResult> result =
        await _connectivity.checkConnectivity();
    final bool isConnected = result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile);
    if (!isConnected && state.isConnected) {
      app.showToast(toastType: HSToastType.warning, title: "You are offline.");
    }
    emit(state.copyWith(isConnected: isConnected));
  }

  Future<void> _onCheckLocationService(
      HSConnectivityCheckLocationServiceEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    final bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!emit.isDone) {
      emit(state.copyWith(isLocationServiceEnabled: isEnabled));
    }
  }

  Future<void> _onRequestLocation(HSConnectivityRequestLocationEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!emit.isDone) {
      emit(state.copyWith(isLocationServiceEnabled: serviceEnabled));
    }

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
      if (!emit.isDone) {
        emit(state.copyWith(location: position));
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _onStopLocationSubscription(
      HSConnectivityStopLocationSubscriptionEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    if (!emit.isDone) {
      emit(state.copyWith(isLocationSubscriptionActive: false));
    }
  }

  Future<void> _onRequestPushNotificationPermission(
      HSConnectivityRequestNotificationPermissionEvent event,
      Emitter<HSConnectivityLocationState> emit) async {
    await FirebaseMessaging.instance.requestPermission();

    await FirebaseMessaging.instance.getAPNSToken();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      add(HSConnectivityFcmTokenChangedEvent(fcmToken));
      await _databaseRepsitory.notifactionChangeFcmToken(
          userID: app.currentUser.uid ?? "", fcmToken: fcmToken);
    }

    HSDebugLogger.logInfo("Notifications permission changed");
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _positionSubscription?.cancel();
    _fcmTokenSubscription?.cancel();
    return super.close();
  }
}
