// part of 'hs_create_spot_cubit.dart';

// enum HSCreateSpotStatus {
//   requestingLocationPermission,
//   choosingLocation,
//   choosingImages,
//   fillingData,
//   submitting,
//   error
// }

// enum HSCreateSpotErrorType {
//   location,
//   photos,
//   unknown,
// }

// final class HSCreateSpotState extends Equatable {
//   const HSCreateSpotState({
//     this.status = HSCreateSpotStatus.choosingLocation,
//     this.currentLocation,
//     this.spotLocation,
//     this.images = const [],
//     this.title = '',
//     this.description = '',
//     this.selectedTags = const [],
//     this.tagsQuery = "",
//     this.queriedTags = const [],
//     this.isLoading = false,
//     this.errorType = HSCreateSpotErrorType.unknown,
//   });

//   final HSCreateSpotStatus status;
//   final Position? currentLocation;
//   final HSLocation? spotLocation;
//   final List<XFile> images;
//   final String title;
//   final String description;
//   final List<String> selectedTags;
//   final List<String> queriedTags;
//   final String tagsQuery;
//   final bool isLoading;
//   final HSCreateSpotErrorType errorType;

//   HSCreateSpotState copyWith({
//     HSCreateSpotStatus? status,
//     Position? currentLocation,
//     HSLocation? spotLocation,
//     List<XFile>? images,
//     String? title,
//     String? description,
//     List<String>? selectedTags,
//     List<String>? queriedTags,
//     String? tagsQuery,
//     bool? isLoading,
//     HSCreateSpotErrorType? errorType,
//   }) {
//     return HSCreateSpotState(
//       status: status ?? this.status,
//       currentLocation: currentLocation ?? this.currentLocation,
//       spotLocation: spotLocation ?? this.spotLocation,
//       images: images ?? this.images,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       selectedTags: selectedTags ?? this.selectedTags,
//       queriedTags: queriedTags ?? this.queriedTags,
//       tagsQuery: tagsQuery ?? this.tagsQuery,
//       isLoading: isLoading ?? this.isLoading,
//       errorType: errorType ?? this.errorType,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         status,
//         spotLocation,
//         currentLocation,
//         images,
//         title,
//         description,
//         selectedTags,
//         queriedTags,
//         tagsQuery,
//         isLoading,
//         errorType,
//       ];
// }
