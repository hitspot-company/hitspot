part of 'hs_connectivity_bloc.dart';

class HSConnectivityLocationState {
  final bool isConnected;
  final Position? location;

  HSConnectivityLocationState({required this.isConnected, this.location});

  HSConnectivityLocationState copyWith(
      {bool? isConnected, Position? location}) {
    return HSConnectivityLocationState(
      isConnected: isConnected ?? this.isConnected,
      location: location ?? this.location,
    );
  }
}
