part of 'hs_create_spot_cubit.dart';

enum HSCreateSpotStatus {
  requestingLocationPermission,
  choosingLocation,
  choosingImages,
  fillingData,
  submitting,
  error
}

final class HSCreateSpotState extends Equatable {
  const HSCreateSpotState({
    this.status = HSCreateSpotStatus.choosingLocation,
    this.currentLocation,
    this.spotLocation,
    this.images = const [],
    this.title = '',
    this.description = '',
    this.tags = const [],
    this.tagsQuery = "",
    this.queriedTags = const [],
    this.isLoading = false,
  });

  final HSCreateSpotStatus status;
  final Position? currentLocation;
  final HSLocation? spotLocation;
  final List<XFile> images;
  final String title;
  final String description;
  final List<String> tags;
  final List<String> queriedTags;
  final String tagsQuery;
  final bool isLoading;

  HSCreateSpotState copyWith({
    HSCreateSpotStatus? status,
    Position? currentLocation,
    HSLocation? spotLocation,
    List<XFile>? images,
    String? title,
    String? description,
    List<String>? tags,
    List<String>? queriedTags,
    String? tagsQuery,
    bool? isLoading,
  }) {
    return HSCreateSpotState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      spotLocation: spotLocation ?? this.spotLocation,
      images: images ?? this.images,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      queriedTags: queriedTags ?? this.queriedTags,
      tagsQuery: tagsQuery ?? this.tagsQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        spotLocation,
        currentLocation,
        images,
        title,
        description,
        tags,
        queriedTags,
        tagsQuery,
        isLoading,
      ];
}
