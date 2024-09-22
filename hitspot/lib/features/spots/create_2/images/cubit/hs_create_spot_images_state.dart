part of 'hs_create_spot_images_cubit.dart';

enum HsCreateSpotImagesStatus { choosingImages, error }

final class HsCreateSpotImagesState extends Equatable {
  const HsCreateSpotImagesState(
      {this.images = const [],
      this.status = HsCreateSpotImagesStatus.choosingImages});

  final List<XFile> images;
  final HsCreateSpotImagesStatus status;

  @override
  List<Object> get props => [images, status];

  HsCreateSpotImagesState copyWith({
    List<XFile>? images,
    HsCreateSpotImagesStatus? status,
  }) {
    return HsCreateSpotImagesState(
      images: images ?? this.images,
      status: status ?? this.status,
    );
  }
}
