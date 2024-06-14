part of 'hs_add_spot_cubit_cubit.dart';

final class HSAddSpotCubitState extends Equatable {
  HSAddSpotCubitState(
      {this.isLoading = true,
      this.usersLocation = const LatLng(0, 0),
      this.location = const LatLng(0, 0),
      this.selectedLocation = const LatLng(0, 0),
      this.selectedLocationStreetName = "",
      this.selectedLocationDistance = "0",
      this.title = "",
      this.description = "",
      this.images = const []});
  final bool isLoading;
  final LatLng usersLocation;
  final LatLng location;
  final LatLng selectedLocation;
  final String selectedLocationStreetName;
  final String selectedLocationDistance;
  final List<XFile> images;
  final String title;
  final String description;

  @override
  List<Object> get props => [
        isLoading,
        usersLocation,
        location,
        selectedLocation,
        selectedLocationStreetName,
        selectedLocationDistance,
        images,
        title,
        description
      ];

  HSAddSpotCubitState copyWith(
      {bool? isLoading,
      LatLng? usersLocation,
      LatLng? location,
      LatLng? selectedLocation,
      String? selectedLocationStreetName,
      String? selectedLocationDistance,
      List<XFile>? images,
      String? title,
      String? description}) {
    return HSAddSpotCubitState(
        isLoading: isLoading ?? this.isLoading,
        usersLocation: usersLocation ?? this.usersLocation,
        location: location ?? this.location,
        selectedLocation: selectedLocation ?? this.selectedLocation,
        selectedLocationStreetName:
            selectedLocationStreetName ?? this.selectedLocationStreetName,
        selectedLocationDistance:
            selectedLocationDistance ?? this.selectedLocationDistance,
        images: images ?? this.images,
        title: title ?? this.title,
        description: description ?? this.description);
  }
}

final class HsAddSpotCubitInitial extends HSAddSpotCubitState {}
