part of 'hs_connectivity_bloc.dart';

class HSConnectivityLocationState {
  final bool isConnected;
  final Position? location;
  final bool isLocationServiceEnabled;
  final bool isLocationSubscriptionActive;

  HSConnectivityLocationState({
    required this.isConnected,
    this.location,
    required this.isLocationServiceEnabled,
    required this.isLocationSubscriptionActive,
  });

  HSConnectivityLocationState copyWith({
    bool? isConnected,
    Position? location,
    bool? isLocationServiceEnabled,
    bool? isLocationSubscriptionActive,
  }) {
    return HSConnectivityLocationState(
      isConnected: isConnected ?? this.isConnected,
      location: location ?? this.location,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      isLocationSubscriptionActive:
          isLocationSubscriptionActive ?? this.isLocationSubscriptionActive,
    );
  }
}
