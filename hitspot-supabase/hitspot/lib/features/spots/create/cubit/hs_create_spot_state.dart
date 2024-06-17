part of 'hs_create_spot_cubit.dart';

enum HSCreateSpotStatus {
  choosingLocation,
  choosingImages,
  fillingData,
  submitting,
  error
}

final class HSCreateSpotState extends Equatable {
  const HSCreateSpotState({
    this.status = HSCreateSpotStatus.choosingLocation,
    // this.location,
    this.images = const [],
    this.title = '',
    this.description = '',
    this.tags = const [],
  });

  final HSCreateSpotStatus status;
  // final LatLng? location;
  final List<XFile> images;
  final String title;
  final String description;
  final List<String> tags;

  HSCreateSpotState copyWith({
    HSCreateSpotStatus? status,
    // LatLng? location,
    List<XFile>? images,
    String? title,
    String? description,
    List<String>? tags,
  }) {
    return HSCreateSpotState(
      status: status ?? this.status,
      // location: location ?? this.location,
      images: images ?? this.images,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        status,
        // location,
        images,
        title,
        description,
        tags,
      ];
}
