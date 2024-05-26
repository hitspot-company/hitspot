part of 'hs_add_spot_cubit_cubit.dart';

final class HSAddSpotCubitState extends Equatable {
  HSAddSpotCubitState(
      {this.isLoading = true,
      this.usersLocation = const LatLng(0, 0),
      this.location = const LatLng(0, 0),
      this.selectedLocation = const LatLng(0, 0),
      this.selectedLocationStreetName = "",
      this.selectedLocationDistance = "0",
      this.step = 0,
      this.title = "",
      this.images = const []});
  final bool isLoading;
  final LatLng usersLocation;
  final LatLng location;
  final LatLng selectedLocation;
  final String selectedLocationStreetName;
  final String selectedLocationDistance;
  final int step;
  final String title;
  final List<XFile> images;

  @override
  List<Object> get props => [
        isLoading,
        usersLocation,
        location,
        selectedLocation,
        selectedLocationStreetName,
        selectedLocationDistance,
        step,
        title,
        images,
      ];

  HSAddSpotCubitState copyWith(
      {bool? isLoading,
      LatLng? usersLocation,
      LatLng? location,
      LatLng? selectedLocation,
      String? selectedLocationStreetName,
      String? selectedLocationDistance,
      int? step,
      String? title,
      List<XFile>? images}) {
    return HSAddSpotCubitState(
        isLoading: isLoading ?? this.isLoading,
        usersLocation: usersLocation ?? this.usersLocation,
        location: location ?? this.location,
        selectedLocation: selectedLocation ?? this.selectedLocation,
        selectedLocationStreetName:
            selectedLocationStreetName ?? this.selectedLocationStreetName,
        selectedLocationDistance:
            selectedLocationDistance ?? this.selectedLocationDistance,
        step: step ?? this.step,
        title: title ?? this.title,
        images: images ?? this.images);
  }
}

final class HsAddSpotCubitInitial extends HSAddSpotCubitState {}
