part of 'hs_connectivity_bloc.dart';

class HSConnectivityLocationState {
  final bool isConnected;
  final Position? location;
  final String? fcmToken;
  final bool isLocationServiceEnabled;
  final bool isLocationSubscriptionActive;

  HSConnectivityLocationState({
    required this.isConnected,
    this.location,
    this.fcmToken,
    required this.isLocationServiceEnabled,
    required this.isLocationSubscriptionActive,
  });

  HSConnectivityLocationState copyWith({
    bool? isConnected,
    Position? location,
    String? fcmToken,
    bool? isLocationServiceEnabled,
    bool? isLocationSubscriptionActive,
  }) {
    return HSConnectivityLocationState(
      isConnected: isConnected ?? this.isConnected,
      location: location ?? this.location,
      fcmToken: fcmToken ?? this.fcmToken,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      isLocationSubscriptionActive:
          isLocationSubscriptionActive ?? this.isLocationSubscriptionActive,
    );
  }
}
