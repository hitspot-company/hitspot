part of 'hs_create_spot_form_cubit.dart';

enum HSCreateSpotFormStatus { fillingData, submitting, error }

final class HSCreateSpotFormState extends Equatable {
  const HSCreateSpotFormState({
    this.status = HSCreateSpotFormStatus.fillingData,
    this.currentLocation,
    this.spotLocation,
    this.images = const [],
    this.title = '',
    this.description = '',
    this.selectedTags = const [],
    this.tagsQuery = "",
    this.queriedTags = const [],
    this.isLoading = false,
  });

  final HSCreateSpotFormStatus status;
  final Position? currentLocation;
  final HSLocation? spotLocation;
  final List<XFile> images;
  final String title;
  final String description;
  final List<String> selectedTags;
  final List<String> queriedTags;
  final String tagsQuery;
  final bool isLoading;

  HSCreateSpotFormState copyWith({
    HSCreateSpotFormStatus? status,
    Position? currentLocation,
    HSLocation? spotLocation,
    List<XFile>? images,
    String? title,
    String? description,
    List<String>? selectedTags,
    List<String>? queriedTags,
    String? tagsQuery,
    bool? isLoading,
  }) {
    return HSCreateSpotFormState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      spotLocation: spotLocation ?? this.spotLocation,
      images: images ?? this.images,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedTags: selectedTags ?? this.selectedTags,
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
        selectedTags,
        queriedTags,
        tagsQuery,
        isLoading,
      ];
}
