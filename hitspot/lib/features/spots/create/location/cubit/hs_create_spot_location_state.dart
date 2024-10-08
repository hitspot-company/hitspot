part of 'hs_create_spot_location_cubit.dart';

enum HsCreateSpotLocationStatus {
  choosingLocation,
  error,
}

final class HsCreateSpotLocationState extends Equatable {
  const HsCreateSpotLocationState(
      {this.status = HsCreateSpotLocationStatus.choosingLocation,
      this.location,
      this.currentLocation});

  final HsCreateSpotLocationStatus status;
  final HSLocation? location;
  final Position? currentLocation;

  HsCreateSpotLocationState copyWith({
    HsCreateSpotLocationStatus? status,
    HSLocation? location,
    Position? currentLocation,
  }) {
    return HsCreateSpotLocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [status, location, currentLocation];
}
