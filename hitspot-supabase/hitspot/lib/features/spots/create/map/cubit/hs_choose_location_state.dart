part of 'hs_choose_location_cubit.dart';

enum HSChooseLocationStatus {
  idle,
  fetchingPlacemark,
  fetchingPredictions,
  error
}

final class HSChooseLocationState extends Equatable {
  const HSChooseLocationState({
    this.status = HSChooseLocationStatus.idle,
    required this.userLocation,
    this.cameraLocation = const LatLng(0, 0),
    this.selectedLocation,
    this.predictions = const [],
    this.isSearching = false,
  });

  final HSChooseLocationStatus status;
  final Position userLocation;
  final LatLng cameraLocation;
  final HSLocation? selectedLocation;
  final List<HSPrediction> predictions;
  final bool isSearching;

  @override
  List<Object?> get props => [
        status,
        userLocation,
        cameraLocation,
        selectedLocation,
        predictions,
        isSearching
      ];

  HSChooseLocationState copyWith({
    HSChooseLocationStatus? status,
    Position? userLocation,
    LatLng? cameraLocation,
    HSLocation? selectedLocation,
    List<HSPrediction>? predictions,
    bool? isSearching,
  }) {
    return HSChooseLocationState(
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
      cameraLocation: cameraLocation ?? this.cameraLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      predictions: predictions ?? this.predictions,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

extension HSPositionExt on Position {
  LatLng get toLatLng {
    return LatLng(latitude, longitude);
  }
}
