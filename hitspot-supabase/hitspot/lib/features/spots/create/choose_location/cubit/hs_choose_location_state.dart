part of 'hs_choose_location_cubit.dart';

final class HsChooseLocationState extends Equatable {
  const HsChooseLocationState(
      {required this.usersLocation,
      this.chosenLocation,
      this.isSearching = false,
      this.location = const LatLng(0, 0),
      this.selectedLocation = const LatLng(0, 0)});

  final Position usersLocation;
  final Placemark? chosenLocation;
  final LatLng location;
  final LatLng selectedLocation;
  final bool isSearching;

  @override
  List<Object?> get props =>
      [usersLocation, chosenLocation, location, selectedLocation, isSearching];

  HsChooseLocationState copyWith({
    Position? usersLocation,
    Placemark? chosenLocation,
    LatLng? location,
    LatLng? selectedLocation,
    bool? isSearching,
  }) {
    return HsChooseLocationState(
      usersLocation: usersLocation ?? this.usersLocation,
      chosenLocation: chosenLocation ?? this.chosenLocation,
      location: location ?? this.location,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

extension HSPositionExt on Position {
  LatLng get toLatLng {
    return LatLng(latitude, longitude);
  }
}
