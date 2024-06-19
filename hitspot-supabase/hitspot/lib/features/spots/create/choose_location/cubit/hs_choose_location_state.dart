part of 'hs_choose_location_cubit.dart';

final class HsChooseLocationState extends Equatable {
  const HsChooseLocationState({
    required this.userLocation,
    this.predictions = const [],
    this.isSearching = false,
    this.selectedPlace,
    this.selectedLocation,
    this.cameraLocation,
  });

  final Position userLocation;
  final HSLocation? selectedLocation;
  final List<HSPrediction> predictions;
  final bool isSearching;
  final HSPlaceDetails? selectedPlace;
  final LatLng? cameraLocation;

  @override
  List<Object?> get props => [
        selectedLocation,
        selectedPlace,
        isSearching,
        predictions,
        cameraLocation
      ];

  HsChooseLocationState copyWith({
    Position? usersLocation,
    Placemark? chosenLocation,
    LatLng? cameraLocation,
    HSLocation? selectedLocation,
    bool? isSearching,
    List<HSPrediction>? predictions,
    HSPlaceDetails? selectedPlace,
  }) {
    return HsChooseLocationState(
      isSearching: isSearching ?? this.isSearching,
      predictions: predictions ?? this.predictions,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      userLocation: userLocation,
    );
  }
}

extension HSPositionExt on Position {
  LatLng get toLatLng {
    return LatLng(latitude, longitude);
  }
}
